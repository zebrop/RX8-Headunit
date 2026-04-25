import QtQuick 6.8
import QtQuick.Controls 6.8

Item {
    id: xypad
    width: 220
    height: 220

    property real xValue: 0.0
    property real yValue: 0.0
    property real step: 0.2

    function clamp(v, minV, maxV) {
        return Math.max(minV, Math.min(maxV, v))
    }

    function snap(v) {
        return Math.round(v / step) * step
    }

    function updateFromPoint(px, py) {
        var nx = (px / width) * 2.0 - 1.0
        var ny = 1.0 - (py / height) * 2.0

        xValue = clamp(nx, -1.0, 1.0)
        yValue = clamp(ny, -1.0, 1.0)
    }

    function snapToStep() {
        xValue = snap(xValue)
        yValue = snap(yValue)
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#666"
        border.width: 1
        radius: 4
    }

    Rectangle {
        width: 2
        height: parent.height
        x: parent.width / 2 - width / 2
        color: "#F6F"
    }

    Rectangle {
        width: parent.width
        height: 2
        y: parent.height / 2 - height / 2
        color: "#F6F"
    }

    Rectangle {
        id: knob
        width: 16
        height: 16
        radius: 8
        color: "white"
        border.color: "#555"
        border.width: 1

        x: ((xyPad.xValue + 1.0) / 2.0) * (xyPad.width - width)
        y: ((1.0 - xyPad.yValue) / 2.0) * (xyPad.height - height)
    }

    MouseArea {
        anchors.fill: parent

        onPressed: xyPad.updateFromPoint(mouse.x, mouse.y)
        onPositionChanged: if (pressed) xyPad.updateFromPoint(mouse.x, mouse.y)
        onReleased: xyPad.snapToStep()
    }
}
