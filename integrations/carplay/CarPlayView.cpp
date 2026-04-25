#include "CarPlayView.h"
#include "CarPlayEngine.h"

#include <QQuickWindow>
#include <QSGSimpleTextureNode>
#include <QSGTexture>

namespace
{
class CarPlayTextureNode : public QSGSimpleTextureNode
{
public:
    quint64 uploadedFrameSerial = 0;
    QSize uploadedTextureSize;
};
}

CarPlayView::CarPlayView(QQuickItem *parent)
    : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
}

QImage CarPlayView::frame() const
{
    return m_frame;
}

void CarPlayView::setFrame(const QImage &frame)
{
    if (m_frame.cacheKey() == frame.cacheKey())
        return;

    m_frame = frame;
    m_frameDirty = true;
    m_geometryDirty = true;

    if (m_textureSize != m_frame.size())
        m_textureSize = m_frame.size();

    updateContentRect();

    emit frameChanged();
    update();
}

CarPlayEngine *CarPlayView::engine() const
{
    return m_engine;
}

void CarPlayView::setEngine(CarPlayEngine *engine)
{
    if (m_engine == engine)
        return;

    if (m_engine)
        disconnect(m_engine, nullptr, this, nullptr);

    m_engine = engine;
    m_lastFrameSerial = 0;
    m_textureSize = QSize();
    m_contentRect = QRectF();
    m_frame = QImage();
    m_frameDirty = true;
    m_geometryDirty = true;

    if (m_engine) {
        connect(m_engine, &CarPlayEngine::frameChanged, this, [this]() {
            syncFrameFromEngine();
        });

        syncFrameFromEngine();
    }

    emit engineChanged();
    emit frameChanged();
    emit contentRectChanged();

    update();
}

bool CarPlayView::hasFrame() const
{
    return !m_frame.isNull();
}

QRectF CarPlayView::contentRect() const
{
    return m_contentRect;
}

void CarPlayView::syncFrameFromEngine()
{
    if (!m_engine)
        return;

    const quint64 serial = m_engine->frameSerial();

    if (serial == m_lastFrameSerial)
        return;

    m_lastFrameSerial = serial;

    const QImage newFrame = m_engine->currentFrame();

    if (newFrame.isNull()) {
        m_frame = QImage();
        m_textureSize = QSize();
        m_contentRect = QRectF();
        m_frameDirty = true;
        m_geometryDirty = true;

        emit frameChanged();
        emit contentRectChanged();

        update();
        return;
    }

    m_frame = newFrame;
    m_frameDirty = true;
    m_geometryDirty = true;

    if (m_textureSize != m_frame.size())
        m_textureSize = m_frame.size();

    updateContentRect();

    emit frameChanged();
    update();
}

QRectF CarPlayView::calculateContentRect() const
{
    if (m_frame.isNull() || width() <= 0 || height() <= 0)
        return QRectF();

    const QSizeF frameSize(m_frame.width(), m_frame.height());
    const QSizeF itemSize(width(), height());

    const QSizeF scaledSize = frameSize.scaled(itemSize, Qt::KeepAspectRatio);

    const qreal x = (itemSize.width() - scaledSize.width()) / 2.0;
    const qreal y = (itemSize.height() - scaledSize.height()) / 2.0;

    return QRectF(x, y, scaledSize.width(), scaledSize.height());
}

void CarPlayView::updateContentRect()
{
    const QRectF newRect = calculateContentRect();

    if (newRect == m_contentRect)
        return;

    m_contentRect = newRect;
    m_geometryDirty = true;

    emit contentRectChanged();
}

void CarPlayView::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);

    if (newGeometry == oldGeometry)
        return;

    updateContentRect();
    update();
}

QSGNode *CarPlayView::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    auto *node = static_cast<CarPlayTextureNode *>(oldNode);

    if (!window() || m_frame.isNull()) {
        delete node;
        return nullptr;
    }

    if (!node) {
        node = new CarPlayTextureNode;
        node->setOwnsTexture(true);
        m_frameDirty = true;
        m_geometryDirty = true;
    }

    const bool needsUpload =
        m_frameDirty ||
        !node->texture() ||
        node->uploadedFrameSerial != m_lastFrameSerial ||
        node->uploadedTextureSize != m_frame.size();

    if (needsUpload) {
        QSGTexture *newTexture = window()->createTextureFromImage(m_frame);

        if (!newTexture)
            return node;

        node->setTexture(newTexture);
        node->setFiltering(QSGTexture::Linear);
        node->uploadedFrameSerial = m_lastFrameSerial;
        node->uploadedTextureSize = m_frame.size();

        m_frameDirty = false;
    }

    if (m_geometryDirty) {
        node->setRect(m_contentRect);
        m_geometryDirty = false;
    }

    return node;
}

void CarPlayView::releaseResources()
{
    m_lastFrameSerial = 0;
    m_frame = QImage();
    m_textureSize = QSize();
    m_contentRect = QRectF();
    m_frameDirty = true;
    m_geometryDirty = true;

    emit frameChanged();
    emit contentRectChanged();
}