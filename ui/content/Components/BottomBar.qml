import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Rx8_HeadUnit

Rectangle {
    id: rectangle
    width: 1280
    height: 120
    opacity: 0.92
    color: Theme.panelBackground

    signal homeClicked()
    signal carPlayClicked()
    signal airConditioningClicked()
    signal mediaClicked()
    signal performanceClicked()
    signal settingsClicked()
    signal themesClicked()
    signal volumeChanged(real value)

    property int currentPage: 0

    property url homeIconSource: ""
    property url carPlayIconSource: ""
    property url airConditioningIconSource: ""
    property url performanceIconSource: ""
    property url mediaIconSource: ""
    property url themesIconSource: ""
    property url settingsIconSource: ""

    function formattedTime() {
        return Qt.formatTime(new Date(), "h:mm AP")
    }

    function formattedDate() {
        return Qt.formatDate(new Date(), "ddd d MMM")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = rectangle.formattedTime()
            dateText.text = rectangle.formattedDate()
        }
    }

    Component.onCompleted: {
        timeText.text = rectangle.formattedTime()
        dateText.text = rectangle.formattedDate()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 12

        PanelBox {
            id: infoBox
            Layout.preferredWidth: 180
            Layout.fillHeight: true

            property bool phoneConnected: false
            property string phoneName: "iPhone 13"

            Column {
                anchors.centerIn: parent
                spacing: 2
                width: parent.width - 20

                Text {
                    id: timeText
                    text: ""
                    color: Theme.textPrimary
                    font.pixelSize: Theme.infoTimeSize
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: dateText
                    text: ""
                    color: Theme.textSecondary
                    font.pixelSize: Theme.infoDateSize
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: 6
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "📱"
                        font.pixelSize: Theme.infoStatusSize
                    }

                    Text {
                        text: infoBox.phoneConnected ? infoBox.phoneName : qsTr("Disconnected")
                        color: infoBox.phoneConnected ? Theme.success : Theme.danger
                        font.pixelSize: Theme.infoStatusSize
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Rectangle {
            color: Theme.divider
            Layout.preferredWidth: 2
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            NavButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Home")
                iconSource: rectangle.homeIconSource
                selected: rectangle.currentPage === 1
                onClicked: rectangle.homeClicked()
            }

            NavButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("CarPlay")
                iconSource: rectangle.carPlayIconSource
                selected: rectangle.currentPage === 3
                onClicked: rectangle.carPlayClicked()
            }

            NavButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("A/C")
                iconSource: rectangle.airConditioningIconSource
                selected: rectangle.currentPage === 4
                onClicked: rectangle.airConditioningClicked()
            }

            NavButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Performance")
                iconSource: rectangle.performanceIconSource
                selected: rectangle.currentPage === 5
                onClicked: rectangle.performanceClicked()
            }

            NavButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Media")
                iconSource: rectangle.mediaIconSource
                selected: rectangle.currentPage === 2
                onClicked: rectangle.mediaClicked()
            }

            NavButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Themes")
                iconSource: rectangle.themesIconSource
                selected: rectangle.currentPage === 6
                onClicked: rectangle.themesClicked()
            }

            NavButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Settings")
                iconSource: rectangle.settingsIconSource
                selected: rectangle.currentPage === 7
                onClicked: rectangle.settingsClicked()
            }
        }

        Rectangle {
            color: Theme.divider
            Layout.preferredWidth: 2
            Layout.fillHeight: true
        }

        VerticalSlider {
            Layout.preferredWidth: 70
            Layout.fillHeight: true
            onSliderValueChanged: function(value) { rectangle.volumeChanged(value) }
        }
    }
}
