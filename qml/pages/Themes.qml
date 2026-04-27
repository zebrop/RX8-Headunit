import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Dialogs
import Rx8_HeadUnit

ThemesForm {
    id: root
    width: 1280
    height: 800

    property int selectedThemeIndex: 0
    property color selectedAccentPreview: Theme.accentColor
    property string selectedBackgroundText: Theme.pageBackground.toString()

    function selectTheme(index) {
        selectedThemeIndex = index
        var data = Theme.themeAt(index)
        Theme.applyTheme(data.id)
        selectedAccentPreview = Theme.accentColor
        selectedBackgroundText = Theme.pageBackground.toString()
    }

    Component.onCompleted: {
        selectTheme(0)
    }

    onThemeRequested: function(index) { selectTheme(index) }
    onEditThemesRequested: modifyDialog.open()

    ColorDialog {
        id: colorDialog
        title: "Choose Accent Colour"
        selectedColor: root.selectedAccentPreview
        onAccepted: {
            root.selectedAccentPreview = selectedColor
            Theme.applyCustomColors(selectedColor, "")
        }
    }

    Dialog {
        id: modifyDialog
        title: "Modify Theme"
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 400
        height: 200

        Column {
            anchors.fill: parent
            spacing: 10

            Button {
                text: "Change Accent Color"
                onClicked: colorDialog.open()
            }

            TextField {
                id: bgField
                placeholderText: "Background URL"
                text: Theme.pageBackground.toString()
            }
        }

        onAccepted: {
            Theme.applyCustomColors(root.selectedAccentPreview, bgField.text)
            root.selectedBackgroundText = Theme.pageBackground.toString()
        }
    }
}
