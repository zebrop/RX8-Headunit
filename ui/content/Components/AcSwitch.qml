import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property bool checked: false

    property color offColor: "#2b2b2b"
    property color onColor: "#ffffff"
    property color thumbOffColor: "#ffffff"
    property color thumbOnColor: "#111111"
    property color textColor: "#ffffff"
    property color borderColor: "#ffffff"

    signal toggled(bool checked)

    implicitWidth: 260
    implicitHeight: 72

    opacity: enabled ? 1.0 : 0.45

    Row {
        anchors.fill: parent
        spacing: 16

        Rectangle {
            id: track
            width: 92
            height: 42
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter

            color: root.checked ? root.onColor : root.offColor
            border.width: root.checked ? 0 : 1
            border.color: root.borderColor

            Rectangle {
                id: thumb
                width: 34
                height: 34
                radius: width / 2
                y: 4
                x: root.checked ? track.width - width - 4 : 4
                color: root.checked ? root.thumbOnColor : root.thumbOffColor

                Behavior on x {
                    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                }
            }
        }

        Text {
            text: root.text
            color: root.textColor
            font.family: Constants.font.family
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled

        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
