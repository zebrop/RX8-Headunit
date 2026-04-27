#include "interface.h"
#include "resource/background.h"
#include "resource/colours.h"
#include "settings.h"
#include "protocol/protocol_const.h"

#include <QColor>
#include <QFont>
#include <QFontMetrics>
#include <QPainter>
#include <QRect>

Interface::Interface()
{
    _backgroundImage.loadFromData(
        reinterpret_cast<const uchar *>(background),
        background_len,
        "BMP");
}

Interface::~Interface()
{
}

void Interface::resetToSplash()
{
    if (m_framebuffer.isNull())
        return;

    m_framebuffer.fill(Qt::black);

    QPainter painter(&m_framebuffer);

    if (!_backgroundImage.isNull()) {
        painter.drawImage(
            QRect(0, 0, m_framebuffer.width(), m_framebuffer.height()),
            _backgroundImage);
    }
}

bool Interface::render(AVFrame *frame)
{
    if (!frame)
        return false;

    if (m_targetWidth <= 0 || m_targetHeight <= 0)
        resize(Settings::width, Settings::height);

    if (!renderFrame(frame))
        return false;

    QPainter painter(&m_framebuffer);

    if (_toast)
        drawToastOverlay(painter);

#ifndef NDEBUG
    if (_debug)
    {
        drawDebugOverlay(painter);
        _debug = false;
    }
#endif

    return true;
}

bool Interface::drawHome(bool force, int state, std::string name)
{
    if (state == _state && !force)
        return false;

    _state = state;

    if (m_targetWidth <= 0 || m_targetHeight <= 0)
        resize(Settings::width, Settings::height);

    if (m_framebuffer.isNull())
        return false;

    m_framebuffer.fill(Qt::black);

    QPainter painter(&m_framebuffer);

    if (!_backgroundImage.isNull())
    {
        painter.drawImage(
            QRect(0, 0, m_framebuffer.width(), m_framebuffer.height()),
            _backgroundImage);
    }

    QString statusText;
    QColor statusColor;

    if (state == PROTOCOL_STATUS_ERROR)
    {
        statusText = "Dongle error";
        statusColor = QColor(colorError.r, colorError.g, colorError.b, colorError.a);
    }
    else if (state == PROTOCOL_STATUS_NO_DEVICE)
    {
        statusText = "Insert dongle";
        statusColor = QColor(colorError.r, colorError.g, colorError.b, colorError.a);
    }
    else if (state == PROTOCOL_STATUS_INITIALISING || state == PROTOCOL_STATUS_LINKING)
    {
        statusText = "Initialising";
        statusColor = QColor(color2.r, color2.g, color2.b, color2.a);
    }
    else if (state == PROTOCOL_STATUS_ONLINE)
    {
        statusText = "Connect phone";
        statusColor = QColor(color4.r, color4.g, color4.b, color4.a);
    }
    else if (state == PROTOCOL_STATUS_CONNECTED)
    {
        if (!name.empty())
            statusText = QString("Connecting to %1").arg(QString::fromStdString(name));
        else
            statusText = "Connecting";
        statusColor = QColor(color3.r, color3.g, color3.b, color3.a);
    }

    if (!statusText.isEmpty())
    {
        QFont font;
        font.setPixelSize(Settings::fontSize);
        painter.setFont(font);
        painter.setPen(statusColor);

        QFontMetrics metrics(font);
        const int textWidth = metrics.horizontalAdvance(statusText);
        const int textHeight = metrics.height();
        const int x = (m_framebuffer.width() - textWidth) / 2;
        const int y = static_cast<int>(m_framebuffer.height() * 0.85) - textHeight;

        painter.drawText(x, y + metrics.ascent(), statusText);
    }

    if (_toast)
        drawToastOverlay(painter);

#ifndef NDEBUG
    if (_debug)
    {
        drawDebugOverlay(painter);
        _debug = false;
    }
#endif

    return true;
}

void Interface::debug(const char *text)
{
    _debugText = text ? QString::fromUtf8(text) : QString();
    _debug = true;
}

void Interface::showToast(const std::string &text)
{
    _toastText = QString::fromStdString(text);
    _toast = true;
}

void Interface::hideToast()
{
    _toastText.clear();
    _toast = false;
}

const QImage &Interface::currentImage() const
{
    return m_framebuffer; // ✅ no copy anymore
}

void Interface::drawDebugOverlay(QPainter &painter)
{
    if (_debugText.isEmpty())
        return;

    constexpr int padding = 8;
    constexpr int lineSpacing = 2;

    QFont font;
    font.setPixelSize(16);
    painter.setFont(font);

    QFontMetrics metrics(font);
    const QStringList lines = _debugText.split('\n');

    int y = padding;

    for (const QString &line : lines)
    {
        const int textWidth = metrics.horizontalAdvance(line);
        const int textHeight = metrics.height();

        QRect bgRect(
            0,
            y,
            textWidth + padding * 2,
            textHeight);

        painter.fillRect(bgRect, QColor(0, 0, 0, 150));
        painter.setPen(QColor(255, 255, 255, 255));
        painter.drawText(padding, y + metrics.ascent(), line);

        y += textHeight + lineSpacing;
    }
}

void Interface::drawToastOverlay(QPainter &painter)
{
    if (_toastText.isEmpty())
        return;

    const int padding = static_cast<int>(Settings::fontSize * 0.3);

    QFont font;
    font.setPixelSize(static_cast<int>(Settings::fontSize * 0.75));
    painter.setFont(font);

    QFontMetrics metrics(font);
    const int textWidth = metrics.horizontalAdvance(_toastText);
    const int textHeight = metrics.height();

    painter.fillRect(
        QRect(0, 0, m_framebuffer.width(), textHeight + padding * 2),
        QColor(0, 0, 0, 150));

    painter.setPen(QColor(color4.r, color4.g, color4.b, color4.a));
    painter.drawText(
        (m_framebuffer.width() - textWidth) / 2,
        padding + metrics.ascent(),
        _toastText);
}