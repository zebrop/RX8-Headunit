import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Item {
    id: xyPad

    width: 220
    height: 220

    property real xValue: 0.0
    property real yValue: 0.0

    property int balancePercent: 0
    property int fadePercent: 0
    property int snapStep: 10

    property real imageTintOpacity: 0.6
    property real imageTintStrength: 1.0
    property real axisTintOpacity: 0.55
    property real knobTintOpacity: 1.0

    function clamp(v, minV, maxV) {
        return Math.max(minV, Math.min(maxV, v))
    }

    function snap(v) {
        return Math.round(v / snapStep) * snapStep
    }

    function updateFromPoint(px, py) {
        var nx = (px / width) * 2.0 - 1.0
        var ny = 1.0 - (py / height) * 2.0

        xValue = clamp(nx, -1.0, 1.0)
        yValue = clamp(ny, -1.0, 1.0)
    }

    function snapToStep() {
        balancePercent = snap(xValue * 100.0)
        fadePercent = snap(yValue * 100.0)

        balancePercent = clamp(balancePercent, -100, 100)
        fadePercent = clamp(fadePercent, -100, 100)

        xValue = balancePercent / 100.0
        yValue = fadePercent / 100.0
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#666666"
        border.width: 1
        radius: 4
    }

    Image {
        id: carInterior
        anchors.fill: parent

        anchors.leftMargin: 6
        anchors.rightMargin: 2
        anchors.topMargin: 4
        anchors.bottomMargin: 4

        source: Qt.resolvedUrl("../../assets/car/interior.png")
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        visible: false
    }

    MultiEffect {
        anchors.fill: carInterior
        source: carInterior

        colorization: xyPad.imageTintStrength
        colorizationColor: Theme.accentColor
        opacity: xyPad.imageTintOpacity
    }

    Rectangle {
        width: 2
        height: parent.height
        x: parent.width / 2 - width / 2
        color: Theme.accentColor
        opacity: xyPad.axisTintOpacity
    }

    Rectangle {
        width: parent.width
        height: 2
        y: parent.height / 2 - height / 2
        color: Theme.accentColor
        opacity: xyPad.axisTintOpacity
    }

    Rectangle {
        id: knob
        width: 24
        height: 24
        radius: 12

        color: Theme.accentColor
        opacity: xyPad.knobTintOpacity

        border.color: "#555555"
        border.width: 1

        x: ((xyPad.xValue + 1.0) / 2.0) * (xyPad.width - width)
        y: ((1.0 - xyPad.yValue) / 2.0) * (xyPad.height - height)
    }

    MouseArea {
        anchors.fill: parent

        onPressed: xyPad.updateFromPoint(mouse.x, mouse.y)

        onPositionChanged: {
            if (pressed)
                xyPad.updateFromPoint(mouse.x, mouse.y)
        }

        onReleased: xyPad.snapToStep()
    }
}
