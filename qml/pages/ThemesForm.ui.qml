/* UI ONLY FILE — Qt Design Studio compatible. */
import QtQuick 6.8
import QtQuick.Controls 6.8
import Rx8_HeadUnit
import "../components"

Rectangle {
    id: root
    width: Constants.width
    height: Constants.height
    color: Theme.backgroundColor

    signal themeRequested(int index)
    signal editThemesRequested()

    Image {
        id: pageBackground
        anchors.fill: parent
        source: Theme.themesPageBackground
        fillMode: Image.PreserveAspectCrop
        smooth: true
        asynchronous: true
        visible: status === Image.Ready
    }

    ThemeButton {
        id: cyanButton
        x: 40
        y: 30
        buttonText: Theme.themeAt(0).name
        glowColor: Theme.themeAt(0).accent
        imageSource: Theme.themeAt(0).previewImage
        selected: Theme.currentTheme === Theme.themeAt(0).id
        onClicked: root.themeRequested(0)
    }

    ThemeButton {
        id: purpleButton
        x: 665
        y: 30
        buttonText: Theme.themeAt(1).name
        glowColor: Theme.themeAt(1).accent
        imageSource: Theme.themeAt(1).previewImage
        selected: Theme.currentTheme === Theme.themeAt(1).id
        onClicked: root.themeRequested(1)
    }

    ThemeButton {
        id: greenButton
        x: 40
        y: 360
        buttonText: Theme.themeAt(2).name
        glowColor: Theme.themeAt(2).accent
        imageSource: Theme.themeAt(2).previewImage
        selected: Theme.currentTheme === Theme.themeAt(2).id
        onClicked: root.themeRequested(2)
    }

    ThemeButton {
        id: editButton
        x: 665
        y: 360
        buttonText: "Edit Themes"
        glowColor: Theme.accentColor
        onClicked: root.editThemesRequested()
    }
}
