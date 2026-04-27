import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property string text: ""
    property url iconSource: ""
    property bool selected: false

    signal clicked()

    implicitWidth: 120
    implicitHeight: 100

    PanelBox {
        anchors.fill: parent
        panelColor: mouseArea.pressed
                    ? Theme.controlPressed
                    : (root.selected ? Theme.controlSelected : Theme.controlIdle)

        opacity: root.enabled ? 1.0 : 0.45

        IconLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -5
            text: root.text
            iconSource: root.iconSource
            iconSize: Theme.navIconSize
            textSize: Theme.navTextSize
            textColor: Theme.textPrimary
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: root.enabled
            onClicked: root.clicked()
        }
    }
}
