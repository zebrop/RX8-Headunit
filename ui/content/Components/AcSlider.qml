import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 50
    property real stepSize: 1

    property bool vertical: true
    property bool gradientFill: false

    property color trackColor: "#2b2b2b"
    property color fillColor: "#ffffff"
    property color handleColor: "#ffffff"
    property color handleBorderColor: "#111111"

    property color coldColor: "#2f80ff"
    property color hotColor: "#ff3b30"

    signal valueChangedByUser(real value)

    implicitWidth: 42
    implicitHeight: 320

    readonly property real range: Math.max(0.0001, root.to - root.from)
    readonly property real normalisedValue: Math.max(0, Math.min(1, (root.value - root.from) / root.range))

    readonly property real trackThickness: root.width
    readonly property real handleSize: root.width
    readonly property real handleInset: root.handleSize / 2
    readonly property real usableLength: Math.max(1, track.height - root.handleSize)

    readonly property real handleCenterY: track.y + root.handleInset
                                          + root.usableLength * (1.0 - root.normalisedValue)

    function setFromPosition(mouseX, mouseY) {
        var raw = 1.0 - Math.max(0, Math.min(1, (mouseY - root.handleInset) / root.usableLength))

        var newValue = root.from + raw * root.range

        if (root.stepSize > 0)
            newValue = Math.round(newValue / root.stepSize) * root.stepSize

        root.value = Math.max(root.from, Math.min(root.to, newValue))
        root.valueChangedByUser(root.value)
    }

    Rectangle {
        id: track

        anchors.centerIn: parent

        width: root.trackThickness
        height: root.height

        radius: width / 2
        color: root.trackColor
    }

    Item {
        id: fillClip

        x: track.x
        y: root.handleCenterY

        width: track.width
        height: track.y + track.height - root.handleCenterY

        clip: true

        Rectangle {
            x: 0
            y: -(fillClip.y - track.y)

            width: track.width
            height: track.height

            radius: track.radius
            color: root.fillColor
            visible: !root.gradientFill
        }

        Rectangle {
            x: 0
            y: -(fillClip.y - track.y)

            width: track.width
            height: track.height

            radius: track.radius
            visible: root.gradientFill

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop {
                    position: 0.0
                    color: root.hotColor
                }

                GradientStop {
                    position: 1.0
                    color: root.coldColor
                }
            }
        }
    }

    Rectangle {
        id: handle

        width: root.handleSize
        height: root.handleSize
        radius: width / 2

        x: track.x + track.width / 2 - width / 2
        y: root.handleCenterY - height / 2

        color: root.handleColor
        border.width: 3
        border.color: root.handleBorderColor
    }

    MouseArea {
        anchors.fill: parent

        onPressed: function(mouse) {
            root.setFromPosition(mouse.x, mouse.y)
        }

        onPositionChanged: function(mouse) {
            if (pressed)
                root.setFromPosition(mouse.x, mouse.y)
        }
    }
}
