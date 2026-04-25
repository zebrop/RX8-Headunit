#include "CarPlayEngine.h"
#include "CarPlayConfig.h"

#include <QTimer>
#include <QMetaObject>
#include <Qt>

#include <algorithm>
#include <exception>

// FastCarPlay
#include "fastcarplay/application.h"
#include "fastcarplay/settings.h"

namespace {
constexpr int kTickIntervalMs = 8;
}

CarPlayEngine::CarPlayEngine(QObject *parent)
    : QObject(parent)
{
    m_tickTimer = new QTimer(this);
    m_tickTimer->setTimerType(Qt::PreciseTimer);
    m_tickTimer->setInterval(kTickIntervalMs);

    connect(m_tickTimer, &QTimer::timeout, this, [this]() {
        pumpOnce();
    });
}

CarPlayEngine::~CarPlayEngine()
{
    stop();
}

bool CarPlayEngine::running() const
{
    return m_running;
}

QImage CarPlayEngine::frame() const
{
    return m_frame;
}

QImage CarPlayEngine::currentFrame() const
{
    return m_frame;
}

int CarPlayEngine::frameWidth() const
{
    return m_frame.width();
}

int CarPlayEngine::frameHeight() const
{
    return m_frame.height();
}

quint64 CarPlayEngine::frameSerial() const
{
    return m_frameSerial;
}

bool CarPlayEngine::hasFrame() const
{
    return !m_frame.isNull();
}

void CarPlayEngine::updateFrame(const QImage &frame)
{
    if (frame.isNull())
        return;

    const bool sizeChanged = frame.size() != m_frame.size();
    const bool contentChanged = m_frame.cacheKey() != frame.cacheKey();

    if (!sizeChanged && !contentChanged)
        return;

    m_frame = frame.copy();
    ++m_frameSerial;

    emit frameChanged();
}

void CarPlayEngine::pumpOnce()
{
    m_pumpPending = false;

    if (!m_running || !m_app)
        return;

    try {
        m_app->tick();

        const QImage latest = m_app->currentFrame();
        if (!latest.isNull())
            updateFrame(latest);

        if (!m_app->isActive())
            stop();
    } catch (const std::exception &e) {
        emit errorMessage(QString("CarPlay runtime error: %1").arg(e.what()));
        stop();
    } catch (...) {
        emit errorMessage("CarPlay runtime error: unknown exception");
        stop();
    }
}

void CarPlayEngine::schedulePump()
{
    if (!m_running || !m_app || m_pumpPending)
        return;

    m_pumpPending = true;

    QMetaObject::invokeMethod(this, [this]() {
        pumpOnce();
    }, Qt::QueuedConnection);
}

void CarPlayEngine::pointerPress(int x, int y)
{
    if (!m_running || !m_app || m_frame.isNull())
        return;

    x = std::clamp(x, 0, m_frame.width() - 1);
    y = std::clamp(y, 0, m_frame.height() - 1);

    m_app->mousePress(x, y);
    schedulePump();
}

void CarPlayEngine::pointerMove(int x, int y)
{
    if (!m_running || !m_app || m_frame.isNull())
        return;

    x = std::clamp(x, 0, m_frame.width() - 1);
    y = std::clamp(y, 0, m_frame.height() - 1);

    m_app->mouseMove(x, y);
    schedulePump();
}

void CarPlayEngine::pointerRelease(int x, int y)
{
    if (!m_running || !m_app || m_frame.isNull())
        return;

    x = std::clamp(x, 0, m_frame.width() - 1);
    y = std::clamp(y, 0, m_frame.height() - 1);

    m_app->mouseRelease(x, y);
    schedulePump();
}

void CarPlayEngine::keyPress(int key)
{
    if (!m_running || !m_app)
        return;

    m_app->keyPress(key);
    schedulePump();
}

void CarPlayEngine::keyRelease(int key)
{
    if (!m_running || !m_app)
        return;

    m_app->keyRelease(key);
    schedulePump();
}

bool CarPlayEngine::start(const QString &settingsPath)
{
    if (m_running)
        return true;

    if (settingsPath.isEmpty()) {
        emit errorMessage("No CarPlay settings file could be resolved");
        return false;
    }

    if (!Settings::load(settingsPath.toStdString().c_str())) {
        emit errorMessage(QString("Failed to load CarPlay settings: %1").arg(settingsPath));
        return false;
    }

    m_frame = QImage();
    m_frameSerial = 0;
    m_pumpPending = false;

    try {
        m_app = std::make_unique<Application>();

        if (!m_app->initialize(CarPlayConfig::carPlayWidth(), CarPlayConfig::carPlayHeight())) {
            emit errorMessage("Failed to initialize FastCarPlay");
            m_app.reset();
            return false;
        }
    } catch (const std::exception &e) {
        emit errorMessage(QString("Failed to initialize FastCarPlay: %1").arg(e.what()));
        m_app.reset();
        return false;
    } catch (...) {
        emit errorMessage("Failed to initialize FastCarPlay: unknown error");
        m_app.reset();
        return false;
    }

    m_running = true;

    emit runningChanged();
    emit frameChanged();

    m_tickTimer->start();
    schedulePump();

    return true;
}

void CarPlayEngine::stop()
{
    if (m_tickTimer)
        m_tickTimer->stop();

    if (m_app) {
        m_app->shutdownRuntime();
        m_app.reset();
    }

    const bool wasRunning = m_running;

    m_frame = QImage();
    ++m_frameSerial;
    m_running = false;
    m_pumpPending = false;

    emit frameChanged();

    if (wasRunning)
        emit runningChanged();
}