import QtQuick 6.8
import QtQuick.Controls 6.8

Popup {
    id: root

    property alias nameText: presetNameField.text

    signal accepted(string name)
    signal cancelled()

    modal: true
    focus: true

    width: 420
    height: 220

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function openForNewPreset() {
        presetNameField.text = ""
        open()
        presetNameField.forceActiveFocus()
    }

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


            color: "white"
            font.pixelSize: 20
            selectByMouse: true

            onAccepted: {
                root.accepted(text)
                root.close()
            }

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

            onClicked: {
                root.cancelled()
                root.close()
            }

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

            onClicked: {
                root.accepted(presetNameField.text)
                root.close()
            }

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
