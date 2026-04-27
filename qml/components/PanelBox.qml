import QtQuick 6.8
import Rx8_HeadUnit

Rectangle {
    id: root

    property color panelColor: Theme.panelBackground
    property color panelBorderColor: Theme.panelBorder
    property int panelRadius: Theme.radiusMedium
    property int panelBorderWidth: 1

    color: panelColor
    radius: panelRadius
    border.color: panelBorderColor
    border.width: panelBorderWidth
}
