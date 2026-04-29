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
    property alias cyanButtonItem: cyanButton
    property alias purpleButtonItem: purpleButton
    property alias greenButtonItem: greenButton
    property alias editButtonItem: editButton

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
        buttonText: "Cyan"
        glowColor: "#73fafd"
        imageSource: Theme.defaultPageBackground
        selected: Theme.currentTheme === "cyan"
    }

    ThemeButton {
        id: purpleButton
        x: 665
        y: 30
        buttonText: "Purple"
        glowColor: "#b879ff"
        imageSource: Theme.defaultPageBackground
        selected: Theme.currentTheme === "purple"
    }

    ThemeButton {
        id: greenButton
        x: 40
        y: 360
        buttonText: "Green"
        glowColor: "#00ffaa"
        imageSource: Theme.defaultPageBackground
        selected: Theme.currentTheme === "green"
    }

    ThemeButton {
        id: editButton
        x: 665
        y: 360
        buttonText: "Edit Themes"
        glowColor: Theme.accentColor
    }
}
