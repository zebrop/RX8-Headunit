import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit
import "../Components"

Rectangle {
    width: 1280
    height: 800
    opacity: 1
    color: "#2a2a2a"

    Image {
        id: pageBackground
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: -4
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        source: Theme.acPageBackground
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        visible: status === Image.Ready

        Text {
            id: text6
            x: 35
            y: 585
            width: 203
            height: 82

            readonly property int leftPercent: Math.round(
                                                   (1.0 - xyPad.xValue) * 50.0)
            readonly property int rightPercent: Math.round(
                                                    (1.0 + xyPad.xValue) * 50.0)

            text: qsTr("Balance  L / R\n" + leftPercent + "% / " + rightPercent + "%")

            font.pixelSize: 22
            font.bold: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: text7
            x: 237
            y: 585
            width: 203
            height: 82

            readonly property int frontPercent: Math.round(
                                                    (1.0 + xyPad.yValue) * 50.0)
            readonly property int rearPercent: Math.round(
                                                   (1.0 - xyPad.yValue) * 50.0)

            text: qsTr("Fade  F / R\n" + frontPercent + "% / " + rearPercent + "%")

            font.pixelSize: 22
            font.bold: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    property alias volumeSlider: volumeSlider
    property alias addPresetButton: addPresetButton
    property alias presetRepeater: presetRepeater
    property alias listView: listView

    property url interiorSource: Qt.resolvedUrl("../../assets/Car/interior.png")

    property var presetModel: ["Flat", "Bass Boost", "Treble Boost", "Rock", "Pop", "Jazz", "Classical", "Vocal", "Electronic", "Hip Hop", "Dance", "R&B", "Podcast", "Movie", "Live", "Acoustic", "Loudness", "Custom"]

    XyPad {
        id: xyPad
        x: 38
        y: 38
        width: 407
        height: 535
        snapStep: 10
    }

    EqualizerPanel {
        id: equalizer
        x: 463
        y: 35
        width: 566
        height: 521

        sliderSpacing: 160
        bellWidthFactor: 0.14
        curveAggressiveness: 1.2
        masterAnimationDuration: 120
    }

    Text {
        id: text1
        x: 565
        y: 47
        text: qsTr("Base")
        font.pixelSize: 21
        color: "#FFFFFF"
    }

    Text {
        id: text2
        x: 729
        y: 47
        text: qsTr("Mid")
        font.pixelSize: 21
        color: "#FFFFFF"
    }

    Text {
        id: text3
        x: 880
        y: 47
        text: qsTr("Treble")
        color: "#FFFFFF"
        font.pixelSize: 21
    }

    AcSlider {
        id: volumeSlider
        x: 463
        y: 619
        width: 787
        height: 30
        value: 15
        stepSize: 1
        vertical: false
        gradientFill: true
        useAccentGradient: true
    }

    Text {
        id: text4
        x: 804
        y: 562
        width: 105
        height: 34
        text: qsTr("Volume")
        font.pixelSize: 30
        color: "#FFFFFF"
    }

    Item {
        id: listView
        x: 1070
        y: 120
        width: 180
        height: 380

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
        x: 1070
        y: 482
        width: 180
        height: 50
        text: qsTr("Add Preset")
    }

    Text {
        id: text5
        width: 180
        x: 1070
        y: 47
        text: qsTr("Presets")
        color: "white"
        font.pixelSize: 22
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }
}
