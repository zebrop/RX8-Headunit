#ifndef SRC_PIPE_LISTENER
#define SRC_PIPE_LISTENER

#include <functional>
#include <thread>

class PipeListener
{
public:
    // onKey is called from the listener thread with the raw byte value read from the pipe.
    PipeListener(const char *path, std::function<void(int)> onKey);
    ~PipeListener();

private:
    void loop();

    const char *_path;
    bool _active;
    std::thread _thread;
    std::function<void(int)> _onKey;
};

#endif /* SRC_PIPE_LISTENER */
