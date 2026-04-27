import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Effects
import Rx8_HeadUnit

Item {
    id: root

    width: 760
    height: 420

    property real sliderTop: 40
    property real sliderBottom: 20
    readonly property real sliderHeight: height - sliderTop - sliderBottom
    readonly property real centerY: sliderTop + sliderHeight / 2

    property real sliderSpacing: 250
    readonly property real sliderWidth: 180

    property real bellTravelPadding: 45
    readonly property real bellTravel: Math.max(1, sliderHeight / 2 - bellTravelPadding)

    property real from: -10
    property real to: 10
    property real stepSize: 1

    property real bassValue: 0
    property real midValue: 0
    property real trebleValue: 0

    property color accentColor: Theme.accentColor

    function shiftedHueColor(base, degrees) {
        return Qt.hsva(
            base.hsvHue + degrees / 360.0,
            base.hsvSaturation,
            base.hsvValue,
            base.a
        )
    }

    property color midColor: accentColor
    property color bassColor: shiftedHueColor(accentColor, -12)
    property color trebleColor: shiftedHueColor(accentColor, 24)

    property real bellWidthFactor: 0.18
    property real curveAggressiveness: 1.0

    property real bellOpacity: 0.55
    property real bellGlowOpacity: 0.24

    property int masterAnimationDuration: 0

    property bool repaintPending: true
    property int repaintIntervalMs: 33

    property real bassVisualValue: bassValue
    property real midVisualValue: midValue
    property real trebleVisualValue: trebleValue

    signal bassChangedByUser(real value)
    signal midChangedByUser(real value)
    signal trebleChangedByUser(real value)

    readonly property real range: Math.max(0.0001, to - from)

    readonly property real bassX: width / 2 - sliderSpacing
    readonly property real midX: width / 2
    readonly property real trebleX: width / 2 + sliderSpacing

    function requestCurvePaint() {
        repaintPending = true
    }

    function forceCurvePaint() {
        repaintPending = false
        eqCanvas.requestPaint()
    }

    onBassVisualValueChanged: requestCurvePaint()
    onMidVisualValueChanged: requestCurvePaint()
    onTrebleVisualValueChanged: requestCurvePaint()
    onAccentColorChanged: requestCurvePaint()
    onBassColorChanged: requestCurvePaint()
    onMidColorChanged: requestCurvePaint()
    onTrebleColorChanged: requestCurvePaint()
    onBellOpacityChanged: requestCurvePaint()
    onBellGlowOpacityChanged: requestCurvePaint()
    onSliderSpacingChanged: requestCurvePaint()
    onBellWidthFactorChanged: requestCurvePaint()
    onCurveAggressivenessChanged: requestCurvePaint()
    onWidthChanged: requestCurvePaint()
    onHeightChanged: requestCurvePaint()
    onSliderTopChanged: requestCurvePaint()
    onSliderBottomChanged: requestCurvePaint()

    Timer {
        interval: root.repaintIntervalMs
        running: true
        repeat: true

        onTriggered: {
            if (root.repaintPending) {
                root.repaintPending = false
                eqCanvas.requestPaint()
            }
        }
    }

    Behavior on bassVisualValue {
        enabled: root.masterAnimationDuration > 0
        NumberAnimation {
            duration: root.masterAnimationDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on midVisualValue {
        enabled: root.masterAnimationDuration > 0
        NumberAnimation {
            duration: root.masterAnimationDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on trebleVisualValue {
        enabled: root.masterAnimationDuration > 0
        NumberAnimation {
            duration: root.masterAnimationDuration
            easing.type: Easing.OutCubic
        }
    }

    function normalized(value) {
        return Math.max(0, Math.min(1, (value - from) / range))
    }

    function gainOffset(value) {
        var signed = (normalized(value) - 0.5) * 2.0
        return signed * bellTravel
    }

    function bellFalloff(x, cx, sigma) {
        var edgeDistance = Math.max(cx, width - cx)
        var exponent = Math.max(0.25, curveAggressiveness * 2.0)

        var edgeRaw = Math.exp(-Math.pow(edgeDistance / sigma, exponent))
        var raw = Math.exp(-Math.pow(Math.abs(x - cx) / sigma, exponent))

        if (edgeRaw >= 0.999)
            return 0

        return Math.max(0, (raw - edgeRaw) / (1.0 - edgeRaw))
    }

    function bellOffset(x, cx, value) {
        var sigma = Math.max(1, width * bellWidthFactor)
        return -gainOffset(value) * bellFalloff(x, cx, sigma)
    }

    Canvas {
        id: eqCanvas
        anchors.fill: parent

        renderTarget: Canvas.Image
        renderStrategy: Canvas.Immediate

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            var cy = root.centerY
            var sigma = Math.max(1, width * root.bellWidthFactor)

            function drawSingleBell(cx, value, color) {
                var amp = root.gainOffset(value)

                if (Math.abs(amp) < 0.5)
                    amp = 0

                var c = Qt.color(color)
                var glowStrength = amp === 0 ? 0.08 : 1.0

                var fill = Qt.rgba(c.r, c.g, c.b, root.bellOpacity * glowStrength).toString()
                var soft = Qt.rgba(c.r, c.g, c.b, root.bellGlowOpacity * glowStrength).toString()
                var clear = Qt.rgba(c.r, c.g, c.b, 0).toString()

                var peakY = cy - amp

                var grad = ctx.createRadialGradient(
                    cx, peakY, 8,
                    cx, peakY, width * 0.48
                )

                grad.addColorStop(0.0, fill)
                grad.addColorStop(0.48, soft)
                grad.addColorStop(1.0, clear)

                ctx.beginPath()
                ctx.moveTo(0, cy)

                for (var x = 0; x <= width; x += 4) {
                    var falloff = root.bellFalloff(x, cx, sigma)
                    var y = cy - amp * falloff
                    ctx.lineTo(x, y)
                }

                ctx.lineTo(width, cy)
                ctx.lineTo(0, cy)
                ctx.closePath()

                ctx.fillStyle = grad
                ctx.globalCompositeOperation = "lighter"
                ctx.fill()
                ctx.globalCompositeOperation = "source-over"
            }

            ctx.beginPath()
            ctx.moveTo(0, cy)
            ctx.lineTo(width, cy)
            ctx.strokeStyle = "rgba(255,255,255,0.18)"
            ctx.lineWidth = 1
            ctx.stroke()

            drawSingleBell(root.bassX, root.bassVisualValue, root.bassColor)
            drawSingleBell(root.midX, root.midVisualValue, root.midColor)
            drawSingleBell(root.trebleX, root.trebleVisualValue, root.trebleColor)

            ctx.beginPath()
            ctx.moveTo(0, cy)

            for (var x2 = 0; x2 <= width; x2 += 4) {
                var yOffset =
                    root.bellOffset(x2, root.bassX, root.bassVisualValue) +
                    root.bellOffset(x2, root.midX, root.midVisualValue) +
                    root.bellOffset(x2, root.trebleX, root.trebleVisualValue)

                ctx.lineTo(x2, cy + yOffset)
            }

            ctx.strokeStyle = "rgba(255,255,255,0.9)"
            ctx.lineWidth = 2.6
            ctx.shadowBlur = 0
            ctx.stroke()
        }
    }

    EqualizerSlider {
        id: bassSlider

        x: root.bassX - width / 2
        y: root.sliderTop
        width: root.sliderWidth
        height: root.sliderHeight

        from: root.from
        to: root.to
        stepSize: root.stepSize
        value: root.bassValue
        liveValue: root.bassVisualValue
        accentColor: root.bassColor

        drawBell: false
        showValueText: true

        onValueChangedByUser: function(v) {
            root.bassValue = v
            root.bassChangedByUser(v)
        }

        onLiveValueChanged: {
            if (Math.abs(root.bassVisualValue - liveValue) > 0.04)
                root.bassVisualValue = liveValue
        }
    }

    EqualizerSlider {
        id: midSlider

        x: root.midX - width / 2
        y: root.sliderTop
        width: root.sliderWidth
        height: root.sliderHeight

        from: root.from
        to: root.to
        stepSize: root.stepSize
        value: root.midValue
        liveValue: root.midVisualValue
        accentColor: root.midColor

        drawBell: false
        showValueText: true

        onValueChangedByUser: function(v) {
            root.midValue = v
            root.midChangedByUser(v)
        }

        onLiveValueChanged: {
            if (Math.abs(root.midVisualValue - liveValue) > 0.04)
                root.midVisualValue = liveValue
        }
    }

    EqualizerSlider {
        id: trebleSlider

        x: root.trebleX - width / 2
        y: root.sliderTop
        width: root.sliderWidth
        height: root.sliderHeight

        from: root.from
        to: root.to
        stepSize: root.stepSize
        value: root.trebleValue
        liveValue: root.trebleVisualValue
        accentColor: root.trebleColor

        drawBell: false
        showValueText: true

        onValueChangedByUser: function(v) {
            root.trebleValue = v
            root.trebleChangedByUser(v)
        }

        onLiveValueChanged: {
            if (Math.abs(root.trebleVisualValue - liveValue) > 0.04)
                root.trebleVisualValue = liveValue
        }
    }
}
