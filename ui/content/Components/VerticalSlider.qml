import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 50
    property string iconText: ""
    property bool showIcon: iconText !== ""

    signal sliderValueChanged(real value)

    implicitWidth: 70
    implicitHeight: 120

    PanelBox {
        anchors.fill: parent

        Text {
            text: root.iconText
            color: Theme.textSecondary
            font.pixelSize: 16
            visible: root.showIcon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 16
        }

        Slider {
            id: slider
            orientation: Qt.Vertical
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            width: 28
            height: root.showIcon ? Math.max(90, parent.height - 40) : Math.max(90, parent.height - 20)

            from: root.from
            to: root.to
            value: root.value

            onValueChanged: function() { root.sliderValueChanged(slider.value) }

            background: Rectangle {
                x: (slider.width - width) / 2
                y: 0
                width: 6
                height: slider.availableHeight
                radius: 3
                color: Theme.sliderTrack

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: (1.0 - slider.visualPosition) * parent.height
                    radius: 3
                    color: Theme.sliderFill
                }
            }

            handle: Rectangle {
                x: (slider.width - width) / 2
                y: slider.visualPosition * (slider.availableHeight - height)
                width: 20
                height: 20
                radius: 10
                color: slider.pressed ? Theme.textPrimary : Theme.sliderHandle
                border.color: Theme.panelBorder
                border.width: 1
            }
        }
    }
}
