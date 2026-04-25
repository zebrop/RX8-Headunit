import QtQuick 6.8

Rectangle {
    color: "black"
    border.color: "#404040"
    border.width: 1

    property var frame
    property var engine

    Text {
        anchors.centerIn: parent
        text: "CarPlay preview"
        color: "white"
        font.pixelSize: 24
    }
}
