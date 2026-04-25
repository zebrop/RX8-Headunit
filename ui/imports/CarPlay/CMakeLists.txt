### Preview-only CarPlay QML stub for Design Studio / QML tooling

qt_add_library(CarPlayModule STATIC)

qt6_add_qml_module(CarPlayModule
    URI "CarPlay"
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    NO_PLUGIN
    QML_FILES
        CarPlayView.qml
)
