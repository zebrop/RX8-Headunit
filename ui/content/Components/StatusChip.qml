import QtQuick 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property string iconText: ""
    property color statusColor: Theme.textSecondary

    implicitWidth: row.implicitWidth + 12
    implicitHeight: 28

    PanelBox {
        anchors.fill: parent
        panelRadius: 14

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: root.iconText
                font.pixelSize: 14
                visible: root.iconText !== ""
            }

            Text {
                text: root.text
                color: root.statusColor
                font.pixelSize: 13
            }
        }
    }
}
