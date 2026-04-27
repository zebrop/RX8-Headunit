import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit
import "../Components"

Rectangle {
    id: root

    width: 1280
    height: 800
    opacity: 1
    color: "#2a2a2a"

    property alias volumeSlider: volumeSlider
    property alias addPresetButton: addPresetButton
    property alias deletePresetModeButton: deletePresetModeButton
    property alias cancelPresetButton: cancelPresetButton
    property alias savePresetButton: savePresetButton
    property alias presetRepeater: presetRepeater
    property alias presetList: listView
    property alias xyPad: xyPad
    property alias equalizer: equalizer
    property alias addPresetPopup: addPresetPopup
    property alias presetNameField: presetNameField

    property url interiorSource: Qt.resolvedUrl("../../assets/Car/interior.png")

    property var presetModel: []
    property bool deleteMode: false
    property string customPresetName: "Custom"

    Image {
        id: pageBackground
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: -4
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        source: Qt.resolvedUrl("../../assets/backgrounds/simple_dark.jpg")
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

    Text {
        id: text5
        width: 180
        x: 1067
        y: 58
        text: qsTr("Presets")
        color: "white"
        font.pixelSize: 22
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
    }

    Item {
        id: listView
        x: 1063
        y: 100
        width: 184
        height: 350

        property int currentIndex: 0

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: presetsColumn.height
            clip: true

            Column {
                id: presetsColumn
                width: parent.width
                spacing: 8

                Repeater {
                    id: presetRepeater
                    model: root.presetModel

                    delegate: Item {
                        width: listView.width
                        height: 44

                        property alias presetButton: presetButton
                        property alias deletePresetButton: deletePresetButton
                        property bool _connected: false

                        Button {
                            id: deletePresetButton

                            visible: root.deleteMode
                                     && modelData.name !== root.customPresetName

                            width: 30
                            height: 30
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

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
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: deletePresetButton.visible ? 42 : 0

                            text: modelData.name

                            background: Rectangle {
                                radius: 10
                                color: index === listView.currentIndex ? "#CCFFFFFF" : "#22000000"
                                border.color: index
                                              === listView.currentIndex ? "#FFFFFFFF" : "#55FFFFFF"
                                border.width: index === listView.currentIndex ? 2 : 1

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    radius: 9
                                    color: Theme.accentColor
                                    opacity: index === listView.currentIndex ? 0.20 : 0.08
                                }
                            }

                            contentItem: Text {
                                text: modelData.name
                                color: index === listView.currentIndex ? "#111111" : "white"
                                font.pixelSize: 17
                                font.bold: index === listView.currentIndex
                                elide: Text.ElideRight
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
        x: 1063
        y: 465
        width: 184
        height: 54
        text: qsTr("Add Preset")

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
        x: 1063
        y: 515
        width: 184
        height: 54
        text: root.deleteMode ? qsTr("Done") : qsTr("Delete Preset")

        background: Rectangle {
            radius: 10
            color: root.deleteMode ? "#66000000" : "#44FF0000"
            border.color: "#88FFFFFF"
            border.width: 1
        }

        contentItem: Text {
            text: deletePresetModeButton.text
            color: root.deleteMode ? "white" : "white"
            font.pixelSize: 15
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Popup {
        id: addPresetPopup
        modal: true
        focus: true
        width: 420
        height: 220
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 18
            color: "#F0202020"
            border.color: "#AAFFFFFF"
            border.width: 1
        }

        contentItem: Item {
            anchors.fill: parent

            Text {
                id: popupTitle
                x: 28
                y: 22
                text: qsTr("Name Preset")
                color: "white"
                font.pixelSize: 26
                font.bold: true
            }

            TextField {
                id: presetNameField
                x: 28
                y: 72
                width: 364
                height: 46
                placeholderText: qsTr("Preset name")
                color: "white"
                font.pixelSize: 20
                selectByMouse: true

                background: Rectangle {
                    radius: 10
                    color: "#33000000"
                    border.color: "#88FFFFFF"
                    border.width: 1
                }
            }

            Button {
                id: cancelPresetButton
                x: 28
                y: 146
                width: 160
                height: 42
                text: qsTr("Cancel")

                background: Rectangle {
                    radius: 10
                    color: "#22000000"
                    border.color: "#66FFFFFF"
                    border.width: 1
                }

                contentItem: Text {
                    text: cancelPresetButton.text
                    color: "white"
                    font.pixelSize: 17
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: savePresetButton
                x: 232
                y: 146
                width: 160
                height: 42
                text: qsTr("Save")

                background: Rectangle {
                    radius: 10
                    color: "#66FFFFFF"
                    border.color: "#FFFFFFFF"
                    border.width: 1
                }

                contentItem: Text {
                    text: savePresetButton.text
                    color: "#111111"
                    font.pixelSize: 17
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
