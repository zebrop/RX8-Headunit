import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property bool checked: false

    signal toggled(bool checked)

    implicitWidth: 180
    implicitHeight: 54

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        Text {
            text: root.text
            color: Theme.textPrimary
            font.pixelSize: Theme.bodyTextSize
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            width: parent.width - 70
        }

        Rectangle {
            id: track
            width: 46
            height: 26
            radius: 13
            color: root.checked ? Theme.accent : Theme.sliderTrack
            opacity: root.enabled ? 1.0 : 0.45
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 22
                height: 22
                radius: 11
                y: 2
                x: root.checked ? parent.width - width - 2 : 2
                color: Theme.textPrimary

                Behavior on x {
                    NumberAnimation { duration: 120 }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.enabled
                onClicked: root.toggled(!root.checked)
            }
        }
    }
}
