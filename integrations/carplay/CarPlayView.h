#pragma once

#include <QImage>
#include <QQuickItem>
#include <QRectF>
#include <QSize>

class CarPlayEngine;
class QSGNode;

class CarPlayView : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QImage frame READ frame WRITE setFrame NOTIFY frameChanged)
    Q_PROPERTY(CarPlayEngine* engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool hasFrame READ hasFrame NOTIFY frameChanged)
    Q_PROPERTY(QRectF contentRect READ contentRect NOTIFY contentRectChanged)

public:
    explicit CarPlayView(QQuickItem *parent = nullptr);

    QImage frame() const;
    void setFrame(const QImage &frame);

    CarPlayEngine *engine() const;
    void setEngine(CarPlayEngine *engine);

    bool hasFrame() const;
    QRectF contentRect() const;

signals:
    void frameChanged();
    void engineChanged();
    void contentRectChanged();

protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;
    void releaseResources() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    void syncFrameFromEngine();
    QRectF calculateContentRect() const;
    void updateContentRect();

private:
    QImage m_frame;
    CarPlayEngine *m_engine = nullptr;

    quint64 m_lastFrameSerial = 0;
    QSize m_textureSize;
    QRectF m_contentRect;

    bool m_frameDirty = false;
    bool m_geometryDirty = true;
};