#ifndef SRC_APPLICATION
#define SRC_APPLICATION

#include <chrono>
#include <memory>
#include <string>
#include <vector>
#include <QImage>

#include "protocol/protocol_const.h"
#include "protocol/connection.h"
#include "renderer.h"
#include "decoder.h"
#include "pcm_audio.h"
#include "interface.h"

#define TOAST_TIME 3

class Application
{
public:
    Application();
    ~Application();

    bool initialize(int width, int height);

    void resize(int width, int height);
    void requestQuit();

    void mousePress(int x, int y);
    void mouseMove(int x, int y);
    void mouseRelease(int x, int y);

    void multiTouch(const QList<int> &ids,
                    const std::vector<int> &xs,
                    const std::vector<int> &ys,
                    const QList<int> &states);

    void keyPress(int key);
    void keyRelease(int key);

    void tick();
    void shutdownRuntime();

    bool isActive() const { return _active; }
    QImage currentFrame() const;

private:
    struct State
    {
        bool dirty = false;
        bool frameRendered = false;
        int requestFrame = 0;
        bool fullscreen = false;
        bool mouseDown = false;
        int8_t latestState = PROTOCOL_STATUS_UNKNOWN;
        uint32_t showToast = 0;
        std::string toast = "";
    };

    int processKey(int keySym);
    int mapKeySymbol(int keySym);
    void handleScriptKey(int keySym);
    const std::string status() const;

    void startRuntime();

    bool _active;
    bool _initialized;
    bool _runtimeStarted;
    State _state;
    int _width;
    int _height;
    bool _debug;

    std::unique_ptr<Interface> _interface;
    std::unique_ptr<Connection> _protocol;
    std::unique_ptr<Decoder> _decoder;
    std::unique_ptr<PcmAudio> _audioMain;
    std::unique_ptr<PcmAudio> _audioAux;

    std::chrono::steady_clock::time_point _frameStart;
    AVFrame *_frame;
    uint32_t _frameId;
    uint32_t _dropframes;
    int _skipEvents;
    int32_t _frameTime;
    int32_t _frameDelay;
    int32_t _frameTarget;

#ifndef NDEBUG
    uint32_t _debugLast;
    int _debugSpeed;
    int _debugLastCount;
#endif
};

#endif /* SRC_APPLICATION */