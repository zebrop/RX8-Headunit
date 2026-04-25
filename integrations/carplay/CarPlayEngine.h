#pragma once

#include <QObject>
#include <QImage>

#include <memory>

class Application;
class QTimer;

class CarPlayEngine : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QImage frame READ frame NOTIFY frameChanged)
    Q_PROPERTY(int frameWidth READ frameWidth NOTIFY frameChanged)
    Q_PROPERTY(int frameHeight READ frameHeight NOTIFY frameChanged)
    Q_PROPERTY(quint64 frameSerial READ frameSerial NOTIFY frameChanged)
    Q_PROPERTY(bool hasFrame READ hasFrame NOTIFY frameChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)

public:
    explicit CarPlayEngine(QObject *parent = nullptr);
    ~CarPlayEngine() override;

    Q_INVOKABLE bool start(const QString &settingsPath);
    Q_INVOKABLE void stop();

    Q_INVOKABLE void pointerPress(int x, int y);
    Q_INVOKABLE void pointerMove(int x, int y);
    Q_INVOKABLE void pointerRelease(int x, int y);

    Q_INVOKABLE void keyPress(int key);
    Q_INVOKABLE void keyRelease(int key);

    bool running() const;
    QImage frame() const;
    QImage currentFrame() const;
    int frameWidth() const;
    int frameHeight() const;
    quint64 frameSerial() const;
    bool hasFrame() const;

signals:
    void runningChanged();
    void frameChanged();
    void errorMessage(const QString &message);

private:
    void updateFrame(const QImage &frame);
    void pumpOnce();
    void schedulePump();

private:
    QTimer *m_tickTimer = nullptr;
    std::unique_ptr<Application> m_app;

    QImage m_frame;
    quint64 m_frameSerial = 0;

    bool m_running = false;
    bool m_pumpPending = false;
};