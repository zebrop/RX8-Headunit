pragma Singleton

import QtQuick 6.8

QtObject {
    readonly property int width: 1280
    readonly property int height: 800

    readonly property color backgroundColor: "#2a2a2a"

    readonly property string fontFamily: "Sans Serif"
    readonly property int fontPixelSize: 18
    readonly property int largeFontPixelSize: 28

    readonly property var font: ({
        family: fontFamily,
        pixelSize: fontPixelSize
    })

    readonly property var largeFont: ({
        family: fontFamily,
        pixelSize: largeFontPixelSize
    })
}
