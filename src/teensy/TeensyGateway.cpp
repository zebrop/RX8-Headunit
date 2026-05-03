#include "TeensyGateway.h"

#include <QCoreApplication>
#include <QDebug>
#include <QProcessEnvironment>
#include <QSerialPortInfo>
#include <QStringList>
#include <QtMath>

TeensyGateway::TeensyGateway(QObject *parent)
    : QObject(parent)
{
    connect(&m_serial, &QSerialPort::readyRead, this, &TeensyGateway::readAvailable);
    connect(&m_serial, &QSerialPort::errorOccurred, this, &TeensyGateway::handleError);
    openSerial();
}

QVariant TeensyGateway::value(const QString &key, QVariant fallback) const
{
    if (!m_values.contains(key))
        return fallback;
    return m_values.value(key);
}

bool TeensyGateway::hasValue(const QString &key) const
{
    return m_values.contains(key);
}

QString TeensyGateway::formattedValue(const QString &key, int decimals, const QString &suffix, const QString &fallback) const
{
    if (!m_values.contains(key))
        return fallback;

    return QString::number(m_values.value(key), 'f', decimals) + suffix;
}

void TeensyGateway::sendCommand(const QString &command)
{
    const QString trimmed = command.trimmed().toLower();
    if (trimmed.isEmpty())
        return;

    if (!m_serial.isOpen()) {
        qWarning() << "Teensy command dropped; serial is not open:" << trimmed;
        return;
    }

    const QByteArray line = "C," + trimmed.toUtf8() + '\n';
    m_serial.write(line);
    m_serial.flush();
    emit commandSent(trimmed);
}

void TeensyGateway::reconnect()
{
    if (m_serial.isOpen())
        m_serial.close();
    openSerial();
}

void TeensyGateway::readAvailable()
{
    m_buffer += m_serial.readAll();

    int newline = -1;
    while ((newline = m_buffer.indexOf('\n')) >= 0) {
        QByteArray line = m_buffer.left(newline);
        m_buffer.remove(0, newline + 1);
        line = line.trimmed();
        if (!line.isEmpty())
            parseLine(line);
    }
}

void TeensyGateway::handleError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::NoError)
        return;

    qWarning() << "Teensy serial error:" << m_serial.errorString();
}

void TeensyGateway::openSerial()
{
    const QStringList ports = candidatePorts();

    for (const QString &port : ports) {
        m_serial.setPortName(port);
        m_serial.setBaudRate(1000000);
        m_serial.setDataBits(QSerialPort::Data8);
        m_serial.setParity(QSerialPort::NoParity);
        m_serial.setStopBits(QSerialPort::OneStop);
        m_serial.setFlowControl(QSerialPort::NoFlowControl);

        if (m_serial.open(QIODevice::ReadWrite)) {
            qInfo() << "Connected to Teensy gateway on" << port;
            emit connectionChanged();
            return;
        }
    }

    qWarning() << "No Teensy gateway serial port opened. Tried:" << ports;
    emit connectionChanged();
}

void TeensyGateway::parseLine(const QByteArray &rawLine)
{
    const QString line = QString::fromUtf8(rawLine).trimmed();
    emit lineReceived(line);

    const QStringList parts = line.split(',', Qt::KeepEmptyParts);
    if (parts.size() < 3)
        return;

    const QString type = parts.at(0).trimmed().toUpper();
    const QString key = parts.at(1).trimmed();
    bool ok = false;
    const double numericValue = parts.at(2).trimmed().toDouble(&ok);
    if (!ok || key.isEmpty())
        return;

    if (type == QStringLiteral("V") || type == QStringLiteral("INFO"))
        setValue(key, numericValue);
}

void TeensyGateway::setValue(const QString &key, double value)
{
    const bool changed = !m_values.contains(key) || !qFuzzyCompare(m_values.value(key) + 1.0, value + 1.0);
    m_values.insert(key, value);

    if (changed) {
        emit valueChanged(key, value);
        emit telemetryChanged();
    }
}

double TeensyGateway::valueDouble(const QString &key, double fallback) const
{
    return m_values.value(key, fallback);
}

int TeensyGateway::valueInt(const QString &key, int fallback) const
{
    if (!m_values.contains(key))
        return fallback;
    return qRound(m_values.value(key));
}

bool TeensyGateway::valueBool(const QString &key) const
{
    return valueInt(key, 0) != 0;
}

QStringList TeensyGateway::candidatePorts() const
{
    QStringList ports;

    const QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    const QString envPort = env.value(QStringLiteral("RX8_TEENSY_PORT")).trimmed();
    if (!envPort.isEmpty())
        ports << envPort;

    ports << QStringLiteral("/dev/ttyAMA0")
          << QStringLiteral("/dev/ttyAMA10")
          << QStringLiteral("/dev/serial0")
          << QStringLiteral("/dev/ttyUSB0")
          << QStringLiteral("/dev/ttyACM0");

    const QList<QSerialPortInfo> infos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : infos) {
        const QString name = info.systemLocation();
        if (!ports.contains(name))
            ports << name;
    }

    ports.removeDuplicates();
    return ports;
}
