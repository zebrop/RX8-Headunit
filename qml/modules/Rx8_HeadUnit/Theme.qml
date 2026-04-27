pragma Singleton
import QtQuick 6.8

QtObject {
    property string currentTheme: "cyan"

    readonly property color panelBackground: "#111111"
    readonly property color panelBorder: "#2a2a2a"
    readonly property color divider: "#666666"

    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#bdbdbd"
    readonly property color textMuted: "#7a7a7a"

    readonly property color accent: accentColor
    readonly property color success: "#8cff8c"
    readonly property color danger: "#ff6b6b"
    readonly property color warning: "#ffcc66"

    readonly property color controlIdle: "transparent"
    readonly property color controlPressed: "#2f2f2f"
    readonly property color controlSelected: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.16)
    readonly property color controlActive: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.24)
    readonly property color controlDisabled: "#555555"

    readonly property color sliderTrack: "#2a2a2a"
    readonly property color sliderFill: accent
    readonly property color sliderHandle: "#d8d8d8"

    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 14

    readonly property int navIconSize: 90
    readonly property int navTextSize: 14
    readonly property int bodyTextSize: 14
    readonly property int titleTextSize: 16
    readonly property int infoTimeSize: 30
    readonly property int infoDateSize: 16
    readonly property int infoStatusSize: 16

    property color backgroundColor: "#2a2a2a"
    property color accentColor: "#73fafd"

    property url pageBackground: defaultPageBackground
    property url loadingPageBackground: defaultPageBackground
    property url homePageBackground: defaultPageBackground
    property url mediaPageBackground: defaultPageBackground
    property url appleCarPlayPageBackground: defaultPageBackground
    property url acPageBackground: defaultPageBackground
    property url performancePageBackground: defaultPageBackground
    property url themesPageBackground: defaultPageBackground
    property url settingsPageBackground: defaultPageBackground

    property url homeIconSource: defaultHomeIcon
    property url carPlayIconSource: defaultCarPlayIcon
    property url airConditioningIconSource: defaultAirConditioningIcon
    property url performanceIconSource: defaultPerformanceIcon
    property url mediaIconSource: defaultMediaIcon
    property url themesIconSource: defaultThemesIcon
    property url settingsIconSource: defaultSettingsIcon

    readonly property bool useResourceAssets: Qt.resolvedUrl("Theme.qml").toString().indexOf("qrc:") === 0
    readonly property url defaultPageBackground: useResourceAssets ? "qrc:/assets/backgrounds/simple_dark.jpg" : Qt.resolvedUrl("../../../assets/backgrounds/simple_dark.jpg")
    readonly property url defaultHomeIcon: useResourceAssets ? "qrc:/assets/icons/Home.png" : Qt.resolvedUrl("../../../assets/icons/Home.png")
    readonly property url defaultCarPlayIcon: useResourceAssets ? "qrc:/assets/icons/CarPlay.png" : Qt.resolvedUrl("../../../assets/icons/CarPlay.png")
    readonly property url defaultAirConditioningIcon: useResourceAssets ? "qrc:/assets/icons/AirConditioning.png" : Qt.resolvedUrl("../../../assets/icons/AirConditioning.png")
    readonly property url defaultPerformanceIcon: useResourceAssets ? "qrc:/assets/icons/Performance.png" : Qt.resolvedUrl("../../../assets/icons/Performance.png")
    readonly property url defaultMediaIcon: useResourceAssets ? "qrc:/assets/icons/Media.png" : Qt.resolvedUrl("../../../assets/icons/Media.png")
    readonly property url defaultThemesIcon: useResourceAssets ? "qrc:/assets/icons/Themes.png" : Qt.resolvedUrl("../../../assets/icons/Themes.png")
    readonly property url defaultSettingsIcon: useResourceAssets ? "qrc:/assets/icons/Settings.png" : Qt.resolvedUrl("../../../assets/icons/Settings.png")

    readonly property var themes: [
        {
            id: "cyan",
            name: "Cyan",
            accent: "#73fafd",
            background: defaultPageBackground,
            loadingBackground: defaultPageBackground,
            homeBackground: defaultPageBackground,
            mediaBackground: defaultPageBackground,
            appleCarPlayBackground: defaultPageBackground,
            acBackground: defaultPageBackground,
            performanceBackground: defaultPageBackground,
            themesBackground: defaultPageBackground,
            settingsBackground: defaultPageBackground,
            previewImage: defaultPageBackground
        },
        {
            id: "purple",
            name: "Purple",
            accent: "#b879ff",
            background: defaultPageBackground,
            loadingBackground: defaultPageBackground,
            homeBackground: defaultPageBackground,
            mediaBackground: defaultPageBackground,
            appleCarPlayBackground: defaultPageBackground,
            acBackground: defaultPageBackground,
            performanceBackground: defaultPageBackground,
            themesBackground: defaultPageBackground,
            settingsBackground: defaultPageBackground,
            previewImage: defaultPageBackground
        },
        {
            id: "green",
            name: "Green",
            accent: "#00ffaa",
            background: defaultPageBackground,
            loadingBackground: defaultPageBackground,
            homeBackground: defaultPageBackground,
            mediaBackground: defaultPageBackground,
            appleCarPlayBackground: defaultPageBackground,
            acBackground: defaultPageBackground,
            performanceBackground: defaultPageBackground,
            themesBackground: defaultPageBackground,
            settingsBackground: defaultPageBackground,
            previewImage: defaultPageBackground
        }
    ]

    function themeAt(index) {
        if (index < 0 || index >= themes.length)
            return themes[0]

        return themes[index]
    }

    function applyTheme(themeId) {
        for (var i = 0; i < themes.length; ++i) {
            if (themes[i].id === themeId) {
                currentTheme = themes[i].id
                accentColor = themes[i].accent
                applyThemeAssets(themes[i])
                return
            }
        }

        applyTheme(themes[0].id)
    }

    function applyCustomColors(accent, background) {
        currentTheme = "custom"
        accentColor = accent

        if (background !== "")
            applySharedBackground(Qt.resolvedUrl(background))
    }

    function themeBackground(theme, pageKey) {
        return theme[pageKey] || theme.background || defaultPageBackground
    }

    function applyThemeAssets(theme) {
        pageBackground = themeBackground(theme, "background")
        loadingPageBackground = themeBackground(theme, "loadingBackground")
        homePageBackground = themeBackground(theme, "homeBackground")
        mediaPageBackground = themeBackground(theme, "mediaBackground")
        appleCarPlayPageBackground = themeBackground(theme, "appleCarPlayBackground")
        acPageBackground = themeBackground(theme, "acBackground")
        performancePageBackground = themeBackground(theme, "performanceBackground")
        themesPageBackground = themeBackground(theme, "themesBackground")
        settingsPageBackground = themeBackground(theme, "settingsBackground")

        applyThemeIcons()
    }

    function applySharedBackground(background) {
        pageBackground = background
        loadingPageBackground = background
        homePageBackground = background
        mediaPageBackground = background
        appleCarPlayPageBackground = background
        acPageBackground = background
        performancePageBackground = background
        themesPageBackground = background
        settingsPageBackground = background

        applyThemeIcons()
    }

    function applyThemeIcons() {
        homeIconSource = defaultHomeIcon
        carPlayIconSource = defaultCarPlayIcon
        airConditioningIconSource = defaultAirConditioningIcon
        performanceIconSource = defaultPerformanceIcon
        mediaIconSource = defaultMediaIcon
        themesIconSource = defaultThemesIcon
        settingsIconSource = defaultSettingsIcon
    }
}
