pragma Singleton
import QtQuick 6.8

QtObject {
    property string currentTheme: "modern_dark"

    readonly property color panelBackground: "#111111"
    readonly property color panelBorder: "#2a2a2a"
    readonly property color divider: "#666666"

    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#bdbdbd"
    readonly property color textMuted: "#7a7a7a"

    readonly property color accent: "#4da6ff"
    readonly property color success: "#8cff8c"
    readonly property color danger: "#ff6b6b"
    readonly property color warning: "#ffcc66"

    readonly property color controlIdle: "transparent"
    readonly property color controlPressed: "#2f2f2f"
    readonly property color controlSelected: "#1f2b38"
    readonly property color controlActive: "#22384f"
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

    readonly property color accentColor: "#73fafd"

    readonly property url acPageBackground: Qt.resolvedUrl("../../assets/backgrounds/simple_dark.jpg")
}
