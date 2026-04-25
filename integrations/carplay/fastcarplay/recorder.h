#ifndef SRC_RECORDER
#define SRC_RECORDER

#include <atomic>
#include <memory>
#include <thread>

#include "struct/atomic_queue.h"
#include "protocol/message.h"

class QAudioSource;
class QAudioDevice;
class QIODevice;

class Recorder
{
public:
    Recorder();
    ~Recorder();

    void start(AtomicQueue<Message> *queue);
    void stop();

private:
    void loop();

    AtomicQueue<Message> *_queue;
    std::atomic<bool> _active;
    std::thread _thread;
    std::unique_ptr<QAudioSource> _source;
    std::unique_ptr<QAudioDevice> _deviceInfo;
    QIODevice *_inputDevice;
};

#endif /* SRC_RECORDER */
