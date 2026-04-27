import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit

Item {
    id: root

    property var presetModel: []
    property int currentIndex: -1
    property int visualIndex: currentIndex
    property bool deleteMode: false
    property string customPresetName: "Custom"

    signal presetClicked(int index)
    signal deleteRequested(int index)
    signal addRequested()

    onCurrentIndexChanged: visualIndex = currentIndex

    Rectangle {
        id: presetPanel
        anchors.fill: parent
        radius: 18
        color: "#30000000"
        border.color: "#55FFFFFF"
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 17
            color: "#22FFFFFF"
            opacity: 0.7
        }
    }

    Text {
        id: title
        anchors.top: parent.top
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        text: qsTr("Presets")
        color: "white"
        font.pixelSize: 22
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }

    ListView {
        id: listView

        property real savedContentY: 0

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: addPresetButton.top

        anchors.topMargin: 10
        anchors.bottomMargin: 8
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        clip: true
        spacing: 6
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        model: root.presetModel
        currentIndex: root.visualIndex

        highlightMoveDuration: 0
        highlightResizeDuration: 0
        highlightFollowsCurrentItem: false
        cacheBuffer: 300

        onMovementStarted: savedContentY = contentY

        onContentYChanged: {
            if (moving || dragging)
                savedContentY = contentY
        }

        onCountChanged: {
            const restoreY = savedContentY
            Qt.callLater(function() {
                listView.contentY = Math.max(
                    0,
                    Math.min(restoreY, listView.contentHeight - listView.height)
                )
            })
        }

        delegate: Item {
            width: listView.width
            height: 48

            readonly property bool selected: index === root.visualIndex

            Button {
                id: deleteButton
                visible: root.deleteMode && modelData.name !== root.customPresetName
                width: 30
                height: 30
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                onClicked: {
                    listView.savedContentY = listView.contentY
                    root.deleteRequested(index)
                }

                background: Rectangle {
                    radius: 15
                    color: "#D0202020"
                    border.color: "#FFFF4A4A"
                    border.width: 2
                }

                contentItem: Text {
                    text: "−"
                    color: "#FFFF4A4A"
                    font.pixelSize: 26
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: presetButton
                anchors.fill: parent
                anchors.leftMargin: deleteButton.visible ? 40 : 0

                text: modelData.name

                onClicked: {
                    root.visualIndex = index
                    root.presetClicked(index)
                }

                background: Rectangle {
                    radius: 10
                    color: selected ? "#CCFFFFFF" : "#22000000"
                    border.color: selected ? "#FFFFFFFF" : "#55FFFFFF"
                    border.width: selected ? 2 : 1

                    Behavior on color {
                        enabled: false
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 9
                        color: Theme.accentColor
                        opacity: selected ? 0.20 : 0.08

                        Behavior on opacity {
                            enabled: false
                        }
                    }
                }

                contentItem: Text {
                    text: modelData.name
                    color: selected ? "#111111" : "white"
                    font.pixelSize: 17
                    font.bold: selected
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color {
                        enabled: false
                    }
                }
            }
        }
    }

    Button {
        id: addPresetButton

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: deletePresetModeButton.top

        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 0

        height: 50

        text: qsTr("Add Preset")
        onClicked: root.addRequested()

        background: Rectangle {
            radius: 10
            color: "#ff000000"
            border.color: "#AAFFFFFF"
            border.width: 1

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 9
                color: Theme.accentColor
                opacity: 0.5
            }
        }

        contentItem: Text {
            text: addPresetButton.text
            color: "white"
            font.pixelSize: 17
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Button {
        id: deletePresetModeButton

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 12

        height: 50

        text: root.deleteMode ? qsTr("Done") : qsTr("Delete Preset")
        onClicked: root.deleteMode = !root.deleteMode

        background: Rectangle {
            radius: 10
            color: root.deleteMode ? "#66000000" : "#44FF0000"
            border.color: "#88FFFFFF"
            border.width: 1
        }

        contentItem: Text {
            text: deletePresetModeButton.text
            color: "white"
            font.pixelSize: 15
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
