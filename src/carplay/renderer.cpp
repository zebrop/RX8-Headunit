#include "renderer.h"
#include "common/logger.h"

Renderer::Renderer() = default;

Renderer::~Renderer()
{
    clear();
}

void Renderer::clear()
{
    if (m_sws) {
        sws_freeContext(m_sws);
        m_sws = nullptr;
    }

    m_sourceWidth = 0;
    m_sourceHeight = 0;
}

void Renderer::resize(int width, int height)
{
    if (m_targetWidth == width &&
        m_targetHeight == height &&
        !m_framebuffer.isNull()) {
        return;
    }

    m_targetWidth = width;
    m_targetHeight = height;

    clear();

    if (width > 0 && height > 0) {
        m_framebuffer = QImage(width, height, QImage::Format_ARGB32);
        m_framebuffer.fill(Qt::black);
    } else {
        m_framebuffer = QImage();
    }

    xScale = 1.0f;
    yScale = 1.0f;
}

bool Renderer::ensureSwsContext(AVFrame *frame)
{
    if (!frame || m_targetWidth <= 0 || m_targetHeight <= 0)
        return false;

    if (m_sws &&
        m_sourceWidth == frame->width &&
        m_sourceHeight == frame->height) {
        return true;
    }

    clear();

    m_sourceWidth = frame->width;
    m_sourceHeight = frame->height;

    m_sws = sws_getContext(
        frame->width,
        frame->height,
        static_cast<AVPixelFormat>(frame->format),
        m_targetWidth,
        m_targetHeight,
        AV_PIX_FMT_BGRA,
        SWS_BILINEAR,
        nullptr,
        nullptr,
        nullptr
    );

    if (!m_sws) {
        log_e("Failed to create sws context");
        return false;
    }

    return true;
}

bool Renderer::renderFrame(AVFrame *frame)
{
    if (!frame || m_framebuffer.isNull())
        return false;

    if (!ensureSwsContext(frame))
        return false;

    uint8_t *dstData[4] = {
        m_framebuffer.bits(), nullptr, nullptr, nullptr
    };

    int dstLinesize[4] = {
        static_cast<int>(m_framebuffer.bytesPerLine()), 0, 0, 0
    };

    m_framebuffer.fill(Qt::black);

    sws_scale(
        m_sws,
        frame->data,
        frame->linesize,
        0,
        frame->height,
        dstData,
        dstLinesize
    );

    if (frame->width > 0 && frame->height > 0) {
        xScale = float(m_targetWidth) / float(frame->width);
        yScale = float(m_targetHeight) / float(frame->height);
    } else {
        xScale = 1.0f;
        yScale = 1.0f;
    }

    return true;
}

const QImage &Renderer::image() const
{
    return m_framebuffer;
}