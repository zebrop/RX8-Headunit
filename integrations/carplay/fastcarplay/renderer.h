#ifndef SRC_RENDERER
#define SRC_RENDERER

extern "C"
{
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
}

#include <QImage>
#include <string>

class Renderer
{
public:
    Renderer();
    virtual ~Renderer();

    void resize(int width, int height);
    bool renderFrame(AVFrame *frame);

    const QImage &image() const;

    float xScale = 1.0f;
    float yScale = 1.0f;

protected:
    void clear();
    bool ensureSwsContext(AVFrame *frame);

    QImage m_framebuffer;
    SwsContext *m_sws = nullptr;
    int m_targetWidth = 0;
    int m_targetHeight = 0;
    int m_sourceWidth = 0;
    int m_sourceHeight = 0;
};

#endif /* SRC_RENDERER */