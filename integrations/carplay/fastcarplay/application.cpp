#include "application.h"

#include <cstdio>
#include <chrono>
#include <thread>
#include <memory>
#include <stdexcept>
#include <algorithm>

#include "struct/video_buffer.h"
#include "common/logger.h"

#include "settings.h"
#include "interface.h"
#include "decoder.h"
#include "pcm_audio.h"
#include "common/functions.h"
#include "protocol/message.h"

static KeySetting<int> *keyMap[] = {
    &Settings::keySiri,
    &Settings::keyNightOn,
    &Settings::keyNightOff,
    &Settings::keyLeft,
    &Settings::keyLeftExtra,
    &Settings::keyRight,
    &Settings::keyRightExtra,
    &Settings::keyEnter,
    &Settings::keyEnterUp,
    &Settings::keyBack,
    &Settings::keyUp,
    &Settings::keyDown,
    &Settings::keyHome,
    &Settings::keyPlay,
    &Settings::keyPause,
    &Settings::keyPlayPause,
    &Settings::keyNext,
    &Settings::keyPrev,
    &Settings::keyAccept,
    &Settings::keyReject,
    &Settings::keyVideoFocus,
    &Settings::keyVideoRelease,
    &Settings::keyNavFocus,
    &Settings::keyNavRelease};

static constexpr size_t keyMapSize = sizeof(keyMap) / sizeof(keyMap[0]);

Application::Application() :
    _active(false),
    _initialized(false),
    _runtimeStarted(false),
    _debug(false),
    _width(0),
    _height(0),
    _frame(nullptr),
    _frameId(0),
    _dropframes(0),
    _skipEvents(0),
    _frameTime(0),
    _frameDelay(0),
    _frameTarget(0)
#ifndef NDEBUG
    , _debugLast(0)
    , _debugSpeed(0)
    , _debugLastCount(0)
#endif
{
    log_v("Creating");
    _debug = Settings::debugOverlay;
}

Application::~Application()
{
    shutdownRuntime();
}

bool Application::initialize(int width, int height)
{
    if (_initialized)
        return true;

    if (width <= 0 || height <= 0)
        return false;

    _width = width;
    _height = height;

    _initialized = true;
    _active = true;
    _state = State{};
    return true;
}

void Application::startRuntime()
{
    if (_runtimeStarted)
        return;

    if (!_initialized)
        throw std::runtime_error("startRuntime before initialize");

    _interface = std::make_unique<Interface>();
    _interface->resize(_width, _height);
    _interface->drawHome(true, PROTOCOL_STATUS_UNKNOWN, "");

    _protocol = std::make_unique<Connection>();
    _decoder = std::make_unique<Decoder>();
    _audioMain = std::make_unique<PcmAudio>("main");
    _audioAux = std::make_unique<PcmAudio>("aux");

    _decoder->start(&_protocol->videoStream, AV_CODEC_ID_H264);
    _audioMain->start(&_protocol->audioStreamMain);
    _audioAux->start(&_protocol->audioStreamAux, _audioMain.get());
    _protocol->start();

    _frameStart = std::chrono::steady_clock::now();
    _runtimeStarted = true;
    _state.dirty = true;
    _state.frameRendered = false;
}

void Application::shutdownRuntime()
{
    if (!_runtimeStarted)
        return;

    _active = false;

    _audioAux.reset();
    _audioMain.reset();
    _decoder.reset();
    _protocol.reset();
    _interface.reset();

    _frame = nullptr;
    _frameId = 0;
    _runtimeStarted = false;
    _state.frameRendered = false;
    _state.mouseDown = false;
    _state.dirty = false;
}

void Application::resize(int width, int height)
{
    _width = width;
    _height = height;

    if (_interface)
        _interface->resize(width, height);

    _state.dirty = true;
}

void Application::requestQuit()
{
    _active = false;
}

void Application::mousePress(int x, int y)
{
    if (!_state.frameRendered || !_protocol || _width <= 0 || _height <= 0)
        return;

    _state.mouseDown = true;

    _protocol->writeQueue.pushDiscard(Message::Click(
        static_cast<float>(x) / static_cast<float>(_width),
        static_cast<float>(y) / static_cast<float>(_height),
        true));
}

void Application::mouseMove(int x, int y)
{
    if (!_state.frameRendered || !_state.mouseDown || !_protocol || _width <= 0 || _height <= 0)
        return;

    _protocol->writeQueue.pushDiscard(Message::Move(
        static_cast<float>(x) / static_cast<float>(_width),
        static_cast<float>(y) / static_cast<float>(_height)));
}

void Application::mouseRelease(int x, int y)
{
    if (!_state.frameRendered || !_protocol || _width <= 0 || _height <= 0)
        return;

    _state.mouseDown = false;

    _protocol->writeQueue.pushDiscard(Message::Click(
        static_cast<float>(x) / static_cast<float>(_width),
        static_cast<float>(y) / static_cast<float>(_height),
        false));
}

void Application::keyPress(int key)
{
    if (!_state.frameRendered || !_protocol)
        return;

    int mapped = mapKeySymbol(key);
    if (mapped > 0)
        _protocol->writeQueue.pushDiscard(Message::Control(mapped));
}

void Application::keyRelease(int key)
{
    if (!_protocol)
        return;

    if (key == Settings::keyEnter)
    {
        _protocol->writeQueue.pushDiscard(
            Message::Control(Settings::keyEnterUp.key));
    }
}

int Application::mapKeySymbol(int keySym)
{
    for (uint8_t i = 0; i < keyMapSize; i++)
    {
        if (keyMap[i]->value == keySym)
            return keyMap[i]->key;
    }
    return 0;
}

void Application::tick()
{
    if (!_active)
        return;

    if (!_runtimeStarted)
        startRuntime();

    if (!_interface || !_protocol || !_decoder)
        return;

    const int8_t protocolState = _protocol->state();
    const bool stateChanged = protocolState != _state.latestState;

    if (stateChanged) {
        if (_state.latestState == PROTOCOL_STATUS_CONNECTED &&
            protocolState != PROTOCOL_STATUS_CONNECTED) {
            _state.frameRendered = false;
            _frame = nullptr;
            _frameId = 0;
        }

        _state.latestState = protocolState;
        _state.dirty = true;
    }

    if (protocolState == PROTOCOL_STATUS_CONNECTED)
    {
        uint32_t latestFrameId = 0;

        if (_decoder->buffer.consume(&_frame, &latestFrameId))
        {
            const bool newFrame = latestFrameId != _frameId;

            if ((newFrame || _state.dirty) && _frame)
            {
                if (_interface->render(_frame))
                {
                    _state.frameRendered = true;
                    _state.dirty = false;
                    _frameId = latestFrameId;
                }
            }
        }
    }
    else
    {
        _state.frameRendered = false;
    }

    if (!_state.frameRendered)
    {
        _interface->drawHome(true, _state.latestState, _protocol->phoneName());
        _state.dirty = false;
    }

    auto now = std::chrono::steady_clock::now();
    _frameTime = static_cast<int32_t>(
        std::chrono::duration_cast<std::chrono::microseconds>(now - _frameStart).count());
    _frameStart = now;
}

QImage Application::currentFrame() const
{
    if (!_interface)
        return {};

    return _interface->currentImage();
}