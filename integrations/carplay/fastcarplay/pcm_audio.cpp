#include "pcm_audio.h"

#include <QAudioDevice>
#include <QAudioFormat>
#include <QAudioSink>
#include <QIODevice>
#include <QMediaDevices>
#include <QThread>

#include <chrono>
#include <cstring>
#include <thread>
#include <time.h>

#include "common/functions.h"
#include "protocol/protocol_const.h"
#include "settings.h"
#include "common/logger.h"

namespace
{
QAudioFormat makeAudioFormat(const ChannelConfig &config)
{
    QAudioFormat format;
    format.setSampleRate(config.rate);
    format.setChannelCount(config.channels);
    format.setSampleFormat(QAudioFormat::Int16);
    return format;
}

QAudioDevice selectOutputDevice()
{
    const QString requested = QString::fromStdString(Settings::audioDriver.value).trimmed();
    const auto devices = QMediaDevices::audioOutputs();
    if (!requested.isEmpty())
    {
        for (const auto &device : devices)
        {
            if (device.description() == requested)
                return device;
        }
        log_w("Requested audio output '%s' was not found, using default output",
              Settings::audioDriver.value.c_str());
    }
    return QMediaDevices::defaultAudioOutput();
}
}

ChannelConfig PcmAudio::_configTable[] = {
    {8000, 1, 1},
    {48000, 2, 4},
    {16000, 1, 2},
    {24000, 1, 2},
    {16000, 2, 2},
};

PcmAudio::PcmAudio(const char *name) : _name("default"),
                                       _fader(nullptr),
                                       _playing(false),
                                       _active(false),
                                       _fade(false),
                                       _config({0, 0, 0}),
                                       _data(nullptr),
                                       _volume(1),
                                       _fadedVolume(Settings::audioFade),
                                       _sink(nullptr),
                                       _deviceInfo(nullptr),
                                       _outputDevice(nullptr)
{
    if (name && std::strlen(name) > 0)
        _name = name;
    log_v("Created %s", _name.c_str());
}

PcmAudio::~PcmAudio()
{
    stop();
    if (_thread.joinable())
        _thread.join();
    log_v("Destroyed %s", _name.c_str());
}

void PcmAudio::start(AtomicQueue<Message> *data, PcmAudio *fader)
{
    if (_active)
        stop();
    if (_thread.joinable())
        _thread.join();

    log_v("Starting %s", _name.c_str());
    _fader = fader;
    _data = data;
    _active = true;
    _thread = std::thread(&PcmAudio::loop, this);
}

void PcmAudio::stop()
{
    if (!_active)
        return;
    log_v("Stopping %s", _name.c_str());
    _active = false;
    if (_data)
        _data->notify();
}

ChannelConfig PcmAudio::getConfig(const Message *msg)
{
    uint8_t type = 0;
    if (msg)
        type = msg->getInt(OFFSET_AUDIO_FORMAT);

    if (type >= 3 && type <= 7)
        return _configTable[type - 3];
    return {44100, 2, 4};
}

bool PcmAudio::isZero(const Message *msg)
{
    const uint64_t *p = reinterpret_cast<const uint64_t *>(msg->data());
    const int n = msg->length() / 8;
    for (int i = 0; i < n; ++i)
    {
        if (p[i] != 0)
            return false;
    }
    return true;
}

void PcmAudio::fade(bool enable)
{
    _fade.store(enable);
    if (!_playing)
        _volume = enable ? Settings::audioFade : 1.0F;
}

void PcmAudio::fade(uint8_t *data, int32_t length)
{
    const bool enableFade = _fade.load();
    if (!enableFade && _volume >= 1)
        return;

    int16_t *buf = reinterpret_cast<int16_t *>(data);
    for (int i = 0; i < length / 2; i++)
    {
        if (enableFade)
        {
            if (_volume - FADE_OUT_SPEED >= _fadedVolume)
                _volume = _volume - FADE_OUT_SPEED;
        }
        else
        {
            if (_volume + FADE_IN_SPEED <= 1)
                _volume = _volume + FADE_IN_SPEED;
        }
        if (_volume < 1)
            buf[i] = static_cast<int16_t>(buf[i] * _volume);
    }
}

int PcmAudio::bufferSizeBytes(ChannelConfig config) const
{
    return Settings::audioBuffer * config.scale * config.channels * static_cast<int>(sizeof(int16_t));
}

bool PcmAudio::openDevice(ChannelConfig config)
{
    closeDevice();

    const QAudioFormat format = makeAudioFormat(config);
    QAudioDevice selected = selectOutputDevice();
    if (selected.isNull())
    {
        log_w("No audio output device available for %s", _name.c_str());
        return false;
    }

    if (!selected.isFormatSupported(format))
    {
        log_w("Audio output '%s' does not support %dHz %s 16-bit PCM for %s",
              selected.description().toUtf8().constData(),
              config.rate,
              (config.channels == 2 ? "stereo" : "mono"),
              _name.c_str());
        return false;
    }

    _deviceInfo = std::make_unique<QAudioDevice>(selected);
    _sink = std::make_unique<QAudioSink>(*_deviceInfo, format);
    _sink->setBufferSize(bufferSizeBytes(config));
    _outputDevice = _sink->start();

    if (!_outputDevice)
    {
        log_w("Failed to start audio output '%s' for %s",
              _deviceInfo->description().toUtf8().constData(),
              _name.c_str());
        _sink.reset();
        _deviceInfo.reset();
        return false;
    }

    _config = config;
    log_i("Opened audio output '%s' for %s %dkHz %s buffer %d bytes",
          _deviceInfo->description().toUtf8().constData(),
          _name.c_str(),
          config.rate,
          (config.channels == 2 ? "stereo" : "mono"),
          bufferSizeBytes(config));
    return true;
}

void PcmAudio::closeDevice()
{
    _outputDevice = nullptr;
    if (_sink)
    {
        _sink->stop();
        _sink.reset();
    }
    _deviceInfo.reset();
    _config = {0, 0, 0};
}

bool PcmAudio::writeAll(const uint8_t *data, int32_t length, int waitTimeMs)
{
    if (!_outputDevice)
        return false;

    int written = 0;
    while (_active && written < length)
    {
        const qint64 chunk = _outputDevice->write(reinterpret_cast<const char *>(data + written),
                                                  static_cast<qint64>(length - written));
        if (chunk > 0)
        {
            written += static_cast<int>(chunk);
            continue;
        }

        if (!_data->waitFor(_active, std::max(2, waitTimeMs / 4)))
            return false;
    }
    return written == length;
}

void PcmAudio::play(ChannelConfig config, int32_t segmentSize)
{
    uint8_t zeroSegments = 0;
    bool nonZero = false;

    int prefill = config.channels == 1 ? Settings::audioDelayCall : Settings::audioDelay;
    const int segmentTimeMs = static_cast<int>(1000.0 * segmentSize / (config.rate * config.channels * 2.0));
    const int waitTimeMs = (prefill + 1) * segmentTimeMs;
    log_i("Prepare to play %s %dkHz %s chunk %d ~%dms prefill %d ~%dms",
          _name.c_str(),
          config.rate,
          (config.channels == 2 ? "stereo" : "mono"),
          segmentSize,
          segmentTimeMs,
          prefill,
          waitTimeMs);

    if (!_data->waitFor(_active, AUDIO_RESET_SECONDS * 1000, prefill))
    {
        _data->clear();
        log_w("Not enough data to play %s %dkHz %s chunk %d ~%dms prefill %d ~%dms",
              _name.c_str(),
              config.rate,
              (config.channels == 2 ? "stereo" : "mono"),
              segmentSize,
              segmentTimeMs,
              prefill,
              waitTimeMs);
        return;
    }

    if (_fader && !_fader->faded())
        QThread::msleep(Settings::audioAuxDelay);

    while (_active)
    {
        std::unique_ptr<Message> segment = _data->pop();
        if (!segment)
            return;
        if (config != getConfig(segment.get()))
            return;

        fade(segment->data(), segment->length());

        if (!_playing && prefill-- <= 0)
        {
            log_d("Start playing %s %dkHz %s",
                  _name.c_str(),
                  config.rate,
                  (config.channels == 2 ? "stereo" : "mono"));
            _playing = true;
        }

        if (!writeAll(segment->data(), segment->length(), waitTimeMs))
            return;

        if (_fader)
        {
            if (isZero(segment.get()))
            {
                if (nonZero && ++zeroSegments == FADE_ZERO_SEGMENTS)
                {
                    log_d("Audio %s is zeroes, fade other channel in", _name.c_str());
                    _fader->fade(false);
                }
            }
            else
            {
                nonZero = true;
                zeroSegments = 0;
                _fader->fade(true);
            }
        }

        if (!_data->waitFor(_active, waitTimeMs))
            return;
    }
}

void PcmAudio::loop()
{
    const std::string threadName = "audio-" + _name;
    setThreadName(threadName.c_str());

    log_d("Started thread %s", _name.c_str());

    time_t playEnd = time(nullptr);
    while (_data && _data->wait(_active))
    {
        const Message *segment = _data->peek();
        if (!segment)
            continue;

        const ChannelConfig config = getConfig(segment);
        if (_config != config && !openDevice(config))
        {
            QThread::msleep(100);
            continue;
        }

        if (difftime(time(nullptr), playEnd) > AUDIO_RESET_SECONDS)
        {
            if (!openDevice(config))
            {
                QThread::msleep(100);
                continue;
            }
        }

        if (_fader)
            _fader->fade(true);
        play(config, segment->length());
        _playing = false;
        if (_fader)
            _fader->fade(false);
        playEnd = time(nullptr);
        log_d("Stop playing %s %dkHz %s",
              _name.c_str(),
              config.rate,
              (config.channels == 2 ? "stereo" : "mono"));
    }

    closeDevice();
    log_v("Stopped thread %s", _name.c_str());
}
