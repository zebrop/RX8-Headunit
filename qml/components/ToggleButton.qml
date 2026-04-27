import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property url iconSource: ""
    property bool checked: false

    signal toggled(bool checked)

    implicitWidth: 140
    implicitHeight: 84

    PanelBox {
        anchors.fill: parent
        panelColor: mouseArea.pressed
                    ? Theme.controlPressed
                    : (root.checked ? Theme.controlActive : Theme.controlIdle)

        opacity: root.enabled ? 1.0 : 0.45

        Column {
            anchors.centerIn: parent
            spacing: 6

            Image {
                width: 22
                height: 22
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: root.iconSource
                visible: root.iconSource !== ""
            }

            Text {
                text: root.text
                color: Theme.textPrimary
                font.pixelSize: Theme.bodyTextSize
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: root.enabled
            onClicked: root.toggled(!root.checked)
        }
    }
}
