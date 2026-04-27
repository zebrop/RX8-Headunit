#ifndef SRC_INTERFACE
#define SRC_INTERFACE

#include "renderer.h"
#include <QString>
#include <string>
#include <QPainter>

class Interface : public Renderer
{
public:
    Interface();
    ~Interface();

    bool render(AVFrame *frame);
    bool drawHome(bool force, int state, std::string name);
    void debug(const char *text);
    void showToast(const std::string &text);
    void hideToast();

    const QImage &currentImage() const;

private:
    void drawDebugOverlay(QPainter &painter);
    void drawToastOverlay(QPainter &painter);
    void resetToSplash();

    int _state = 0;
    bool _debug = false;
    bool _toast = false;
    QString _debugText;
    QString _toastText;
    QImage _backgroundImage;
    QImage _currentImage;
};

#endif /* SRC_INTERFACE */