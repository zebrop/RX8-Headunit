#include "recorder.h"

#include <QAudioDevice>
#include <QAudioFormat>
#include <QAudioSource>
#include <QIODevice>
#include <QMediaDevices>
#include <QThread>

#include <algorithm>
#include <cstring>
#include <iostream>
#include <vector>

#include "common/functions.h"
#include "common/logger.h"
#include "protocol/protocol_const.h"
#include "settings.h"

namespace
{
QAudioFormat makeRecorderFormat()
{
    QAudioFormat format;
    format.setSampleRate(16000);
    format.setChannelCount(1);
    format.setSampleFormat(QAudioFormat::Int16);
    return format;
}

QAudioDevice selectInputDevice()
{
    const QString requested = QString::fromStdString(Settings::audioDriver.value).trimmed();
    const auto devices = QMediaDevices::audioInputs();
    if (!requested.isEmpty())
    {
        for (const auto &device : devices)
        {
            if (device.description() == requested)
                return device;
        }
    }
    return QMediaDevices::defaultAudioInput();
}
}

Recorder::Recorder()
    : _queue(nullptr),
      _active(false),
      _thread(),
      _source(nullptr),
      _deviceInfo(nullptr),
      _inputDevice(nullptr)
{
}

Recorder::~Recorder()
{
    stop();
}

void Recorder::start(AtomicQueue<Message> *queue)
{
    if (_active)
        return;

    if (_thread.joinable())
        _thread.join();

    _queue = queue;
    _active = true;
    _thread = std::thread(&Recorder::loop, this);
}

void Recorder::stop()
{
    if (!_active)
        return;

    _active = false;
    if (_thread.joinable())
        _thread.join();
}

void Recorder::loop()
{
    setThreadName("audio-record");

    const QAudioFormat format = makeRecorderFormat();
    QAudioDevice selected = selectInputDevice();
    if (selected.isNull())
    {
        log_w("No audio input device available for recording");
        _active = false;
        return;
    }

    if (!selected.isFormatSupported(format))
    {
        log_w("Audio input '%s' does not support 16kHz mono 16-bit PCM",
              selected.description().toUtf8().constData());
        _active = false;
        return;
    }

    _deviceInfo = std::make_unique<QAudioDevice>(selected);
    _source = std::make_unique<QAudioSource>(*_deviceInfo, format);
    _source->setBufferSize(AUDIO_BUFFER_SIZE * 4);
    _inputDevice = _source->start();

    if (!_inputDevice)
    {
        log_w("Failed to start audio input '%s'",
              _deviceInfo->description().toUtf8().constData());
        _source.reset();
        _deviceInfo.reset();
        _active = false;
        return;
    }

    log_i("Opened audio input '%s' for 16kHz mono capture",
          _deviceInfo->description().toUtf8().constData());

    std::vector<char> buffer(static_cast<size_t>(AUDIO_BUFFER_SIZE));
    while (_active)
    {
        const qint64 available = _inputDevice->bytesAvailable();
        if (available <= 0)
        {
            QThread::msleep(5);
            continue;
        }

        const qint64 bytesToRead = std::min<qint64>(available, static_cast<qint64>(buffer.size()));
        const qint64 bytesRead = _inputDevice->read(buffer.data(), bytesToRead);
        if (bytesRead <= 0)
        {
            QThread::msleep(2);
            continue;
        }

        std::unique_ptr<Message> message = Message::Audio(static_cast<int>(bytesRead));
        if (!message || !message->allocated())
            continue;

        std::memcpy(message->data(), buffer.data(), static_cast<size_t>(bytesRead));
        _queue->pushDiscard(std::move(message));
    }

    _inputDevice = nullptr;
    if (_source)
    {
        _source->stop();
        _source.reset();
    }
    _deviceInfo.reset();
}
