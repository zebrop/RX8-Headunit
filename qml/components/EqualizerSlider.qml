import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Item {
    id: root

    property string title: "BASS"

    property real from: -10
    property real to: 10
    property real value: 0
    property real liveValue: value
    property real stepSize: 1

    property color accentColor: "#28dfff"
    property color textColor: "#ffffff"

    property int trackWidth: 30
    property int handleWidth: 46
    property int handleHeight: 24

    property real topMargin: 50
    property real bottomMargin: 50

    property real bellWidthFactor: 0.24
    property real bellOpacity: 0.7
    property real bellGlowOpacity: 0.25

    property bool drawBell: true
    property bool showValueText: true

    signal valueChangedByUser(real value)

    width: 260
    height: 360

    readonly property real trackHeight: Math.max(20, height - topMargin - bottomMargin)
    readonly property real range: to - from
    readonly property real normalizedValue: range === 0 ? 0.5 : (liveValue - from) / range
    readonly property real n: Math.max(0, Math.min(1, normalizedValue))

    readonly property real centerY: track.y + track.height / 2
    readonly property real handleCenterY: track.y + (1.0 - n) * track.height
    readonly property real gainOffset: centerY - handleCenterY

    onValueChanged: {
        if (!dragArea.pressed)
            liveValue = value

        bellCanvas.requestPaint()
    }

    onLiveValueChanged: bellCanvas.requestPaint()
    onAccentColorChanged: bellCanvas.requestPaint()
    onWidthChanged: bellCanvas.requestPaint()
    onHeightChanged: bellCanvas.requestPaint()
    onDrawBellChanged: bellCanvas.requestPaint()
    onTopMarginChanged: bellCanvas.requestPaint()
    onBottomMarginChanged: bellCanvas.requestPaint()

    Canvas {
        id: bellCanvas
        anchors.fill: parent
        visible: root.drawBell

        renderTarget: Canvas.Image
        renderStrategy: Canvas.Immediate

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            var cx = width / 2
            var cy = root.centerY
            var amp = root.gainOffset
            var sigma = Math.max(1, width * root.bellWidthFactor)

            var edgeDistance = width / 2
            var edgeFalloff = Math.exp(-(edgeDistance * edgeDistance) / (2 * sigma * sigma))

            function bellFalloff(x) {
                var d = x - cx
                var raw = Math.exp(-(d * d) / (2 * sigma * sigma))
                return Math.max(0, (raw - edgeFalloff) / (1.0 - edgeFalloff))
            }

            if (Math.abs(amp) < 0.5)
                amp = 0

            var peakY = cy - amp
            var glowStrength = amp === 0 ? 0.12 : 1.0

            var fillColor = Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, root.bellOpacity * glowStrength).toString()
            var softColor = Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, root.bellGlowOpacity * glowStrength).toString()
            var clearColor = Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.0).toString()
            var solidColor = root.accentColor.toString()

            var grad = ctx.createRadialGradient(cx, peakY, 10, cx, peakY, width * 0.7)
            grad.addColorStop(0.0, fillColor)
            grad.addColorStop(0.45, softColor)
            grad.addColorStop(1.0, clearColor)

            ctx.beginPath()
            ctx.moveTo(0, cy)

            for (var x = 0; x <= width; x += 2) {
                var falloff = bellFalloff(x)
                var y = cy - amp * falloff
                ctx.lineTo(x, y)
            }

            ctx.lineTo(width, cy)
            ctx.lineTo(0, cy)
            ctx.closePath()
            ctx.fillStyle = grad
            ctx.fill()

            ctx.beginPath()
            ctx.moveTo(0, cy)

            for (var x2 = 0; x2 <= width; x2 += 2) {
                var falloff2 = bellFalloff(x2)
                var y2 = cy - amp * falloff2
                ctx.lineTo(x2, y2)
            }

            ctx.strokeStyle = amp === 0
                    ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.55).toString()
                    : solidColor
            ctx.lineWidth = amp === 0 ? 1.6 : 2.4
            ctx.shadowColor = solidColor
            ctx.shadowBlur = amp === 0 ? 5 : 18
            ctx.stroke()
        }
    }

    Rectangle {
        id: track
        width: root.trackWidth
        height: root.trackHeight
        radius: width / 2
        x: parent.width / 2 - width / 2
        y: root.topMargin

        color: "#071018"
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4)
        border.width: 2
    }

    Rectangle {
        x: track.x - 20
        y: root.centerY
        width: track.width + 40
        height: 1
        color: Qt.rgba(255, 255, 255, 0.25)
    }

    Rectangle {
        width: track.width * 0.4
        radius: width / 2
        anchors.horizontalCenter: track.horizontalCenter

        y: Math.min(root.handleCenterY, root.centerY)
        height: Math.abs(root.centerY - root.handleCenterY)

        color: root.accentColor
        visible: height > 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.7
            shadowColor: root.accentColor
        }
    }

    Rectangle {
        id: handle
        width: root.handleWidth
        height: root.handleHeight
        radius: 8
        x: parent.width / 2 - width / 2
        y: root.handleCenterY - height / 2

        color: Qt.lighter(root.accentColor, 1.3)
        border.color: "#eaffff"
        border.width: 2

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.6
            shadowColor: root.accentColor
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: track
        anchors.margins: -40

        onPressed: updateLiveValue(mouseY)

        onPositionChanged: {
            if (pressed)
                updateLiveValue(mouseY)
        }

        onReleased: {
            var snapped = Math.round(root.liveValue / root.stepSize) * root.stepSize
            snapped = Math.max(root.from, Math.min(root.to, snapped))

            root.liveValue = snapped
            root.valueChangedByUser(snapped)
        }

        function updateLiveValue(localY) {
            var yInTrack = Math.max(0, Math.min(track.height, localY - track.y))
            var n = 1.0 - yInTrack / track.height
            var raw = root.from + n * root.range

            root.liveValue = Math.max(root.from, Math.min(root.to, raw))
        }
    }

    Text {
        visible: root.showValueText

        text: {
            var shown = dragArea.pressed ? root.liveValue : root.value
            var rounded = Math.round(shown * 10) / 10
            return rounded > 0 ? "+" + rounded + " dB" : rounded + " dB"
        }

        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height - height+8
        color: root.accentColor
        font.pixelSize: 24
    }
}
