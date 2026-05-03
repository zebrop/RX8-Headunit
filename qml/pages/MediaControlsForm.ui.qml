import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Rectangle {
    id: root

    width: 1280
    height: 800
    opacity: 1
    color: Theme.backgroundColor

    property alias volumeSlider: volumeSlider
    property alias xyPad: xyPad
    property alias equalizer: equalizer

    property alias addPresetPopup: addPresetPopup
    property alias presetBox: presetBox
    property var presetModel: []
    property int currentPresetIndex: 0
    property string customPresetName: "Custom"

    property url interiorSource: "qrc:/qt/qml/content/assets/car/interior.png"

    Image {
        id: pageBackground
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: -4
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        source: Theme.mediaPageBackground
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
        masterAnimationDuration: 0
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

    Rectangle {
        id: presetPanel
        x: 1048
        y: 47
        width: 214
        height: 521
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

    PresetBox {
        id: presetBox
        x: 1048
        y: 47
        width: 214
        height: 521

        presetModel: root.presetModel
        currentIndex: root.currentPresetIndex
        customPresetName: root.customPresetName
    }

    AddPresetPopup {
        id: addPresetPopup
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)
    }
}
