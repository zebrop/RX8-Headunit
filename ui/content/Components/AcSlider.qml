import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 50
    property real stepSize: 1

    property bool vertical: false
    property bool gradientFill: false

    property color trackColor: "#2b2b2b"
    property color fillColor: "#ffffff"
    property color handleColor: "#ffffff"
    property color handleBorderColor: "#111111"

    property color coldColor: "#2f80ff"
    property color hotColor: "#ff3b30"

    signal valueChangedByUser(real value)

    implicitWidth: vertical ? 70 : 320
    implicitHeight: vertical ? 320 : 70

    readonly property real range: Math.max(0.0001, to - from)
    readonly property real normalisedValue: Math.max(0, Math.min(1, (value - from) / range))

    function setFromPosition(mouseX, mouseY) {
        var raw

        if (vertical)
            raw = 1.0 - Math.max(0, Math.min(1, mouseY / height))
        else
            raw = Math.max(0, Math.min(1, mouseX / width))

        var newValue = from + raw * range

        if (stepSize > 0)
            newValue = Math.round(newValue / stepSize) * stepSize

        value = Math.max(from, Math.min(to, newValue))
        valueChangedByUser(value)
    }

    Rectangle {
        id: track
        anchors.centerIn: parent
        width: root.vertical ? 18 : parent.width
        height: root.vertical ? parent.height : 18
        radius: 9
        color: root.trackColor
    }

    Item {
        id: fillClip

        x: root.vertical ? track.x : track.x
        y: root.vertical ? track.y + track.height * (1.0 - root.normalisedValue) : track.y
        width: root.vertical ? track.width : track.width * root.normalisedValue
        height: root.vertical ? track.height * root.normalisedValue : track.height

        clip: true

        Rectangle {
            anchors.fill: parent
            radius: 9
            color: root.fillColor
            visible: !root.gradientFill
        }

        Rectangle {
            radius: 9
            visible: root.gradientFill

            x: root.vertical ? 0 : 0
            y: root.vertical ? -track.height * (1.0 - root.normalisedValue) : 0
            width: root.vertical ? track.width : track.width
            height: root.vertical ? track.height : track.height

            gradient: Gradient {
                orientation: root.vertical ? Gradient.Vertical : Gradient.Horizontal

                GradientStop {
                    position: 0.0
                    color: root.vertical ? root.hotColor : root.coldColor
                }

                GradientStop {
                    position: 1.0
                    color: root.vertical ? root.coldColor : root.hotColor
                }
            }
        }
    }

    Rectangle {
        id: handle
        width: 42
        height: 42
        radius: width / 2

        x: root.vertical
           ? track.x + track.width / 2 - width / 2
           : track.x + track.width * root.normalisedValue - width / 2

        y: root.vertical
           ? track.y + track.height * (1.0 - root.normalisedValue) - height / 2
           : track.y + track.height / 2 - height / 2

        color: root.handleColor
        border.width: 3
        border.color: root.handleBorderColor
    }

    MouseArea {
        anchors.fill: parent

        onPressed: root.setFromPosition(mouse.x, mouse.y)
        onPositionChanged: {
            if (pressed)
                root.setFromPosition(mouse.x, mouse.y)
        }
    }
}
