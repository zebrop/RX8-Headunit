import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit
import "../Components"

Rectangle {
    width: Constants.width
    height: Constants.height
    opacity: 1
    color: "#2a2a2a"

    property alias trebleDownButton: trebleDownButton
    property alias trebleUpButton: trebleUpButton
    property alias trebleSlider: trebleSlider
    property alias midDownButton: midDownButton
    property alias midUpButton: midUpButton
    property alias midSlider: midSlider
    property alias baseDownButton: baseDownButton
    property alias baseUpButton: baseUpButton
    property alias baseSlider: baseSlider
    property alias volumeDownButton: volumeDownButton
    property alias volumeUpButton: volumeUpButton
    property alias volumeSlider: volumeSlider
    property alias addPresetButton: addPresetButton
    property alias presetRepeater: presetRepeater
    property alias listView: listView

    property var presetModel: ["Flat", "Bass Boost", "Treble Boost", "Rock", "Pop", "Jazz", "Classical", "Vocal", "Electronic", "Hip Hop", "Dance", "R&B", "Podcast", "Movie", "Live", "Acoustic", "Loudness", "Custom"]

    Text {
        text: qsTr("Media Page")
        anchors.verticalCenterOffset: -383
        anchors.horizontalCenterOffset: 3
        anchors.centerIn: parent
        font.family: Constants.font.family
    }

    XyPad {
        id: xyPad
        x: 38

        y: 38
        width: 407
        height: 499
    }

    Slider {
        id: baseSlider
        orientation: Qt.Vertical
        x: 561
        y: 80
        width: 20
        height: 400
        snapMode: RangeSlider.SnapOnRelease
        stepSize: 1
        to: 10
        value: 5
    }

    Slider {
        id: trebleSlider
        orientation: Qt.Vertical
        x: 881
        y: 80
        width: 20
        height: 400
        stepSize: 1
        snapMode: RangeSlider.SnapOnRelease
        to: 10
        value: 5
    }

    Slider {
        id: midSlider
        orientation: Qt.Vertical
        x: 721
        y: 80
        width: 20
        height: 400
        snapMode: RangeSlider.SnapOnRelease
        stepSize: 1
        to: 10
        value: 5
    }

    RoundButton {
        id: baseUpButton
        x: 545
        y: 30
        text: "+"
    }

    RoundButton {
        id: midUpButton
        x: 705
        y: 28
        text: "+"
    }

    RoundButton {
        id: trebleUpButton
        x: 865
        y: 30
        text: "+"
    }

    RoundButton {
        id: trebleDownButton
        x: 865
        y: 479
        text: "-"
    }

    RoundButton {
        id: midDownButton
        x: 705
        y: 479
        text: "-"
    }

    RoundButton {
        id: baseDownButton
        x: 545
        y: 481
        text: "-"
    }

    Text {
        id: text1
        x: 549
        y: 539
        text: qsTr("Base")
        font.pixelSize: 21
    }

    Text {
        id: text2
        x: 713
        y: 539
        text: qsTr("Mid")
        font.pixelSize: 21
    }

    Text {
        id: text3
        x: 861
        y: 539
        text: qsTr("Treble")
        font.pixelSize: 21
    }

    Slider {
        id: volumeSlider
        x: 193
        y: 586
        width: 895
        height: 48
        value: 15
        stepSize: 1
        snapMode: RangeSlider.SnapOnRelease
        to: 30
    }

    RoundButton {
        id: volumeUpButton
        x: 1093
        y: 584
        text: "+"
        rotation: -0.043
    }

    RoundButton {
        id: volumeDownButton
        x: 145
        y: 584
        text: "-"
    }

    Text {
        id: text4
        x: 603
        y: 624
        width: 74
        height: 26
        text: qsTr("Volume")
        font.pixelSize: 21
    }

    Item {
        id: listView
        x: 1019
        y: 99
        width: 200
        height: 400

        property int currentIndex: 0

        Flickable {
            anchors.fill: parent
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: -33
            anchors.bottomMargin: 33
            contentWidth: width
            contentHeight: presetsColumn.height
            clip: true

            Column {
                id: presetsColumn
                width: parent.width
                spacing: 8

                Repeater {
                    id: presetRepeater
                    model: presetModel

                    delegate: Item {
                        width: listView.width
                        height: 50

                        property alias presetButton: presetButton
                        property bool _connected: false

                        Button {
                            id: presetButton
                            anchors.fill: parent
                            text: modelData

                            background: Rectangle {
                                radius: 8
                                color: index === listView.currentIndex ? "#66FFFFFF" : "transparent"
                                border.color: index
                                              === listView.currentIndex ? "#FFFFFFFF" : "#55FFFFFF"
                                border.width: index === listView.currentIndex ? 2 : 1
                            }

                            contentItem: Text {
                                text: modelData
                                color: index === listView.currentIndex ? "#000000" : "white"
                                font.pixelSize: 18
                                font.bold: index === listView.currentIndex
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }

    Button {
        id: addPresetButton
        x: 1019
        y: 489
        width: 200
        height: 50
        text: qsTr("Add Preset")
    }

    Text {
        id: text5
        width: 200
        x: 1019
        y: 32
        text: qsTr("Presets")
        color: "white"
        font.pixelSize: 22
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }
}
