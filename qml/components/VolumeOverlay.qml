import QtQuick 6.8
import QtQuick.Controls 6.8

Item{
    id: volumeOverlay
    anchors.fill: parent

    property real reservedBottom: 80
    property int previousVolume: 15
    property bool expanded: false
    property bool longPressTriggered: false
    property string currentTime: ""
    property string currentDate: ""

    function toggleMute() {
        if (volumeSlider.value > 0) {
            volumeOverlay.previousVolume = volumeSlider.value
            volumeSlider.value = 0
        } else {
            volumeSlider.value = volumeOverlay.previousVolume > 0 ? volumeOverlay.previousVolume : 15
        }
    }

    function updateDateTime() {
        const now = new Date()
        volumeOverlay.currentTime = Qt.formatTime(now, "hh:mm")
        volumeOverlay.currentDate = Qt.formatDate(now, "ddd dd MMM")
    }

    Component.onCompleted: updateDateTime()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: volumeOverlay.updateDateTime()
    }

    Rectangle {
        id: panel
        width: 80
        height: volumeOverlay.height - volumeOverlay.reservedBottom
        x: volumeOverlay.width - width
        y: 0
        z: 999
        opacity: 0.833
        color: "#111111"
        border.color: "#444"
        border.width: 1

        Button {
            id: volumeButton
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 24
            height: 50
            text: volumeSlider.value > 0 ? "\uD83D\uDD0A" : "\uD83D\uDD07"

            onPressed: volumeOverlay.longPressTriggered = false

            onPressAndHold: {
                volumeOverlay.longPressTriggered = true
                volumeOverlay.toggleMute()
            }

            onReleased: {
                if (!volumeOverlay.longPressTriggered)
                    volumeOverlay.expanded = !volumeOverlay.expanded
            }

            background: Rectangle {
                radius: height / 2
                color: volumeButton.pressed ? "#bbb" : "#ddd"
                border.color: "#666"
                border.width: 1
            }

            contentItem: Text {
                text: volumeButton.text
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "#111111"
            }
        }

        Item {
            id: controlsArea
            anchors.top: volumeButton.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footer.top
            anchors.bottomMargin: 12

            clip: true
            visible: volumeOverlay.expanded
            opacity: volumeOverlay.expanded ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 120 }
            }

            Column {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                Text {
                    id: volumeText
                    text: Math.round(volumeSlider.value)
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    color: "#ffffff"
                }

                Item {
                    width: parent.width
                    height: parent.height - volumeText.height

                    Slider {
                        id: volumeSlider
                        orientation: Qt.Vertical
                        anchors.centerIn: parent
                        height: parent.height
                        width: 40

                        from: 0
                        to: 30
                        stepSize: 1
                        value: 15

                        onValueChanged: {
                            if (value > 0)
                                volumeOverlay.previousVolume = value
                        }

                        background: Rectangle {
                            x: parent.width / 2 - width / 2
                            y: 0
                            width: 4
                            height: parent.height
                            radius: 2
                            color: "#666"
                        }

                        handle: Rectangle {
                            width: 28
                            height: 28
                            radius: 14
                            color: "#f0f0f0"
                            border.color: "#555"
                            border.width: 1

                            x: volumeSlider.leftPadding + (volumeSlider.availableWidth - width) / 2
                            y: volumeSlider.topPadding
                               + (volumeSlider.visualPosition) * (volumeSlider.availableHeight - height)
                        }
                    }
                }
            }
        }

        Column {
            id: footer
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 12
            spacing: 2

            Text {
                id: timeText
                width: parent.width
                text: volumeOverlay.currentTime
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
                color: "#ffffff"
            }

            Text {
                id: dateText
                width: parent.width
                text: volumeOverlay.currentDate
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
                color: "#cccccc"
            }
        }
    }
}
