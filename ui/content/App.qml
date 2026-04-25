import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import "Pages"
import "Components"

Window {
    id: root
    width: 1280
    height: 800
    visible: true
    color: "#f6f6f6"
    title: "Rx8_HeadUnit"

    readonly property int pageLoading: 0
    readonly property int pageHome: 1
    readonly property int pageMediaControls: 2
    readonly property int pageAppleCarPlay: 3
    readonly property int pageAirConditioning: 4
    readonly property int pagePerformance: 5
    readonly property int pageThemes: 6
    readonly property int pageSettings: 7

    function showLoading()         { stack.currentIndex = pageLoading }
    function showHome()            { stack.currentIndex = pageHome }
    function showMediaControls()   { stack.currentIndex = pageMediaControls }
    function showAppleCarPlay()    { stack.currentIndex = pageAppleCarPlay }
    function showAirConditioning() { stack.currentIndex = pageAirConditioning }
    function showPerformance()     { stack.currentIndex = pagePerformance }
    function showThemes()          { stack.currentIndex = pageThemes }
    function showSettings()        { stack.currentIndex = pageSettings }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: pageLoading

            Loading { }
            Home { }
            MediaControls { }
            AppleCarPlay { }
            AirConditioning { }
            Performance { }
            Themes { }
            Settings { }
        }

        BottomBar {
            id: bottomBar
            homeIconSource: Qt.resolvedUrl("../assets/Icons/Default/Home.png")
            carPlayIconSource: Qt.resolvedUrl("../assets/Icons/Default/CarPlay.png")
            airConditioningIconSource: Qt.resolvedUrl("../assets/Icons/Default/AirConditioning.png")
            performanceIconSource: Qt.resolvedUrl("../assets/Icons/Default/Performance.png")
            mediaIconSource: Qt.resolvedUrl("../assets/Icons/Default/Media.png")
            themesIconSource: Qt.resolvedUrl("../assets/Icons/Default/Themes.png")
            settingsIconSource: Qt.resolvedUrl("../assets/Icons/Default/Settings.png")

            Layout.fillWidth: true
            Layout.preferredHeight: 120
            visible: stack.currentIndex !== pageLoading
            currentPage: stack.currentIndex

            onHomeClicked: root.showHome()
            onCarPlayClicked: root.showAppleCarPlay()
            onAirConditioningClicked: root.showAirConditioning()
            onMediaClicked: root.showMediaControls()
            onPerformanceClicked: root.showPerformance()
            onThemesClicked: root.showThemes()
            onSettingsClicked: root.showSettings()
            
            phoneConnected: typeof carPlayEngine !== "undefined" && carPlayEngine.phoneConnected
            phoneName: phoneConnected ? carPlayEngine.phoneName : ""
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: false
        onTriggered: root.showHome()
    }
}
