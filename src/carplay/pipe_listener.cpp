#include "pipe_listener.h"

#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdexcept>

#include "common/logger.h"

PipeListener::PipeListener(const char *path, std::function<void(int)> onKey)
    : _path(path), _active(false), _onKey(std::move(onKey))
{
    if (path == nullptr)
        return;
    unlink(_path);
    if (mkfifo(_path, 0666) == -1 && errno != EEXIST)
        throw std::runtime_error(std::string("[Pipe] Failed to create FIFO ") + _path + ": " + std::strerror(errno));

    _active = true;
    _thread = std::thread(&PipeListener::loop, this);
}

PipeListener::~PipeListener()
{
    if (!_active)
        return;
    _active = false;
    int tmp = open(_path, O_WRONLY | O_NONBLOCK);
    if (tmp >= 0)
    {
        write(tmp, "\0", 1);
        close(tmp);
    }
    if (_thread.joinable())
        _thread.join();
    unlink(_path);
}

void PipeListener::loop()
{
    log_i("Listening on %s", _path);
    while (_active)
    {
        int fd = open(_path, O_RDONLY);
        if (fd == -1)
        {
            log_e("Failed to open %s: %s", _path, std::strerror(errno));
            return;
        }

        char value;
        while (_active && read(fd, &value, 1) > 0)
        {
            log_d("Received: %d", static_cast<int>(value));
            if (value != 0 && _onKey)
                _onKey(static_cast<int>(value));
        }

        if (fd >= 0)
            close(fd);
    }
    log_v("Finished on %s", _path);
}
