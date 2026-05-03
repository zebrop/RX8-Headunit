#pragma once

#include <QObject>
#include <QSerialPort>
#include <QHash>
#include <QVariant>
#include <QElapsedTimer>

class TeensyGateway : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool connected READ connected NOTIFY connectionChanged)
    Q_PROPERTY(QString portName READ portName NOTIFY connectionChanged)
    Q_PROPERTY(int protocolVersion READ protocolVersion NOTIFY telemetryChanged)

    Q_PROPERTY(bool acRxValid READ acRxValid NOTIFY telemetryChanged)
    Q_PROPERTY(double acTemp READ acTemp NOTIFY telemetryChanged)
    Q_PROPERTY(int acFan READ acFan NOTIFY telemetryChanged)
    Q_PROPERTY(int acMode READ acMode NOTIFY telemetryChanged)
    Q_PROPERTY(bool acAmpOn READ acAmpOn NOTIFY telemetryChanged)
    Q_PROPERTY(bool acRunning READ acRunning NOTIFY telemetryChanged)
    Q_PROPERTY(bool acAuto READ acAuto NOTIFY telemetryChanged)
    Q_PROPERTY(bool acCompressor READ acCompressor NOTIFY telemetryChanged)
    Q_PROPERTY(bool acEco READ acEco NOTIFY telemetryChanged)
    Q_PROPERTY(bool acAmbient READ acAmbient NOTIFY telemetryChanged)
    Q_PROPERTY(int acAirSource READ acAirSource NOTIFY telemetryChanged)
    Q_PROPERTY(bool acFrontDemist READ acFrontDemist NOTIFY telemetryChanged)
    Q_PROPERTY(bool acRearDemist READ acRearDemist NOTIFY telemetryChanged)

    Q_PROPERTY(double rpm READ rpm NOTIFY telemetryChanged)
    Q_PROPERTY(double speedKmh READ speedKmh NOTIFY telemetryChanged)
    Q_PROPERTY(double throttlePedalPercent READ throttlePedalPercent NOTIFY telemetryChanged)
    Q_PROPERTY(double coolantC READ coolantC NOTIFY telemetryChanged)
    Q_PROPERTY(double iatC READ iatC NOTIFY telemetryChanged)
    Q_PROPERTY(double batteryV READ batteryV NOTIFY telemetryChanged)
    Q_PROPERTY(double fuelLevelPercent READ fuelLevelPercent NOTIFY telemetryChanged)
    Q_PROPERTY(double mafGps READ mafGps NOTIFY telemetryChanged)
    Q_PROPERTY(double actualAfr READ actualAfr NOTIFY telemetryChanged)
    Q_PROPERTY(double commandedAfr READ commandedAfr NOTIFY telemetryChanged)
    Q_PROPERTY(double instantL100km READ instantL100km NOTIFY telemetryChanged)
    Q_PROPERTY(double instantLph READ instantLph NOTIFY telemetryChanged)
    Q_PROPERTY(int instantFuelMode READ instantFuelMode NOTIFY telemetryChanged)
    Q_PROPERTY(double steeringWheelDeg READ steeringWheelDeg NOTIFY telemetryChanged)
    Q_PROPERTY(double roadWheelEstDeg READ roadWheelEstDeg NOTIFY telemetryChanged)
    Q_PROPERTY(double wheelFlKmh READ wheelFlKmh NOTIFY telemetryChanged)
    Q_PROPERTY(double wheelFrKmh READ wheelFrKmh NOTIFY telemetryChanged)
    Q_PROPERTY(double wheelRlKmh READ wheelRlKmh NOTIFY telemetryChanged)
    Q_PROPERTY(double wheelRrKmh READ wheelRrKmh NOTIFY telemetryChanged)

public:
    explicit TeensyGateway(QObject *parent = nullptr);

    bool connected() const { return m_serial.isOpen(); }
    QString portName() const { return m_serial.portName(); }
    int protocolVersion() const { return valueInt(QStringLiteral("protocol"), 0); }

    bool acRxValid() const { return valueBool(QStringLiteral("ac_rx_valid")); }
    double acTemp() const { return valueDouble(QStringLiteral("ac_temp"), 22.0); }
    int acFan() const { return valueInt(QStringLiteral("ac_fan"), 0); }
    int acMode() const { return valueInt(QStringLiteral("ac_mode"), 0); }
    bool acAmpOn() const { return valueBool(QStringLiteral("ac_amp_on")); }
    bool acRunning() const { return valueBool(QStringLiteral("ac_running")); }
    bool acAuto() const { return valueBool(QStringLiteral("ac_auto")); }
    bool acCompressor() const { return valueBool(QStringLiteral("ac_compressor")); }
    bool acEco() const { return valueBool(QStringLiteral("ac_eco")); }
    bool acAmbient() const { return valueBool(QStringLiteral("ac_amp_ambient")); }
    int acAirSource() const { return valueInt(QStringLiteral("ac_air_source"), 1); }
    bool acFrontDemist() const { return valueBool(QStringLiteral("ac_front_demist")); }
    bool acRearDemist() const { return valueBool(QStringLiteral("ac_rear_demist")); }

    double rpm() const { return valueDouble(QStringLiteral("rpm")); }
    double speedKmh() const { return valueDouble(QStringLiteral("speed_kmh")); }
    double throttlePedalPercent() const { return valueDouble(QStringLiteral("throttle_pedal_percent")); }
    double coolantC() const { return valueDouble(QStringLiteral("coolant_c")); }
    double iatC() const { return valueDouble(QStringLiteral("iat_c")); }
    double batteryV() const { return valueDouble(QStringLiteral("battery_v")); }
    double fuelLevelPercent() const { return valueDouble(QStringLiteral("fuel_level_percent")); }
    double mafGps() const { return valueDouble(QStringLiteral("maf_gps")); }
    double actualAfr() const { return valueDouble(QStringLiteral("actual_afr")); }
    double commandedAfr() const { return valueDouble(QStringLiteral("commanded_afr")); }
    double instantL100km() const { return valueDouble(QStringLiteral("inst_l_100km")); }
    double instantLph() const { return valueDouble(QStringLiteral("inst_l_h")); }
    int instantFuelMode() const { return valueInt(QStringLiteral("inst_fuel_mode"), 0); }
    double steeringWheelDeg() const { return valueDouble(QStringLiteral("steering_wheel_deg")); }
    double roadWheelEstDeg() const { return valueDouble(QStringLiteral("road_wheel_est_deg")); }
    double wheelFlKmh() const { return valueDouble(QStringLiteral("wheel_fl_kmh")); }
    double wheelFrKmh() const { return valueDouble(QStringLiteral("wheel_fr_kmh")); }
    double wheelRlKmh() const { return valueDouble(QStringLiteral("wheel_rl_kmh")); }
    double wheelRrKmh() const { return valueDouble(QStringLiteral("wheel_rr_kmh")); }

    Q_INVOKABLE QVariant value(const QString &key, QVariant fallback = QVariant()) const;
    Q_INVOKABLE bool hasValue(const QString &key) const;
    Q_INVOKABLE QString formattedValue(const QString &key, int decimals, const QString &suffix = QString(), const QString &fallback = QStringLiteral("--")) const;
    Q_INVOKABLE void sendCommand(const QString &command);
    Q_INVOKABLE void reconnect();

signals:
    void telemetryChanged();
    void valueChanged(const QString &key, double value);
    void connectionChanged();
    void commandSent(const QString &command);
    void lineReceived(const QString &line);

private slots:
    void readAvailable();
    void handleError(QSerialPort::SerialPortError error);

private:
    void openSerial();
    void parseLine(const QByteArray &line);
    void setValue(const QString &key, double value);
    double valueDouble(const QString &key, double fallback = 0.0) const;
    int valueInt(const QString &key, int fallback = 0) const;
    bool valueBool(const QString &key) const;
    QStringList candidatePorts() const;

    QSerialPort m_serial;
    QByteArray m_buffer;
    QHash<QString, double> m_values;
};
