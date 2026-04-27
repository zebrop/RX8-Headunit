import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property url iconSource: ""
    property bool active: false

    signal clicked()

    implicitWidth: 140
    implicitHeight: 72

    PanelBox {
        anchors.fill: parent
        panelColor: mouseArea.pressed
                    ? Theme.controlPressed
                    : (root.active ? Theme.controlActive : Theme.controlIdle)

        opacity: root.enabled ? 1.0 : 0.45

        Row {
            anchors.centerIn: parent
            spacing: 8

            Image {
                width: 20
                height: 20
                fillMode: Image.PreserveAspectFit
                source: root.iconSource
                visible: root.iconSource !== ""
            }

            Text {
                text: root.text
                color: Theme.textPrimary
                font.pixelSize: Theme.titleTextSize
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: root.enabled
            onClicked: root.clicked()
        }
    }
}
