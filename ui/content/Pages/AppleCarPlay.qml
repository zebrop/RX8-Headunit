import QtQuick 6.8
import QtQuick.Controls 6.8
import CarPlay 1.0

AppleCarPlayForm {
    id: root
    width: 1280
    height: 800

    readonly property bool hasCarPlayEngine: (typeof carPlayEngine !== "undefined") && carPlayEngine !== null
    readonly property bool readyForInput: hasCarPlayEngine && carPlayEngine.hasFrame
    readonly property string resolvedCarPlaySettingsPath: (typeof carPlaySettingsPath !== "undefined") ? carPlaySettingsPath : ""

    property bool touchActive: false
    property int activeTouchId: -1
    property real lastTouchX: 0
    property real lastTouchY: 0

    // 🔥 NEW: correct mapping using contentRect
    function mapToFrameX(x) {
        if (!readyForInput)
            return 0

        let rect = carPlayView.contentRect

        if (rect.width <= 0)
            return 0

        let localX = x - rect.x
        localX = Math.max(0, Math.min(localX, rect.width))

        return Math.round(localX * carPlayEngine.frameWidth / rect.width)
    }

    function mapToFrameY(y) {
        if (!readyForInput)
            return 0

        let rect = carPlayView.contentRect

        if (rect.height <= 0)
            return 0

        let localY = y - rect.y
        localY = Math.max(0, Math.min(localY, rect.height))

        return Math.round(localY * carPlayEngine.frameHeight / rect.height)
    }

    function sendPointerPress(x, y) {
        if (!hasCarPlayEngine || !readyForInput)
            return
        carPlayEngine.pointerPress(mapToFrameX(x), mapToFrameY(y))
    }

    function sendPointerMove(x, y) {
        if (!hasCarPlayEngine || !readyForInput)
            return
        carPlayEngine.pointerMove(mapToFrameX(x), mapToFrameY(y))
    }

    function sendPointerRelease(x, y) {
        if (!hasCarPlayEngine || !readyForInput)
            return
        carPlayEngine.pointerRelease(mapToFrameX(x), mapToFrameY(y))
    }

    function beginTouch(point) {
        touchActive = true
        activeTouchId = point.pointId
        lastTouchX = point.x
        lastTouchY = point.y
        sendPointerPress(point.x, point.y)
    }

    function updateTouch(point) {
        if (!touchActive || point.pointId !== activeTouchId)
            return

        lastTouchX = point.x
        lastTouchY = point.y
        sendPointerMove(point.x, point.y)
    }

    function endTouch(point) {
        if (!touchActive || point.pointId !== activeTouchId)
            return

        lastTouchX = point.x
        lastTouchY = point.y
        sendPointerRelease(point.x, point.y)
        touchActive = false
        activeTouchId = -1
    }

    function cancelTouch() {
        if (!touchActive)
            return

        sendPointerRelease(lastTouchX, lastTouchY)
        touchActive = false
        activeTouchId = -1
    }

    Component.onCompleted: {
        if (hasCarPlayEngine)
            carPlayEngine.start(resolvedCarPlaySettingsPath)
    }

    Item {
        anchors.fill: parent

        CarPlayView {
            id: carPlayView
            anchors.fill: parent
            layer.enabled: true
            engine: hasCarPlayEngine ? carPlayEngine : null
        }

        Item {
            id: inputLayer
            anchors.fill: parent
            z: 100

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                preventStealing: true
                enabled: readyForInput && !root.touchActive

                onPressed: function(mouse) {
                    if (mouse.source !== Qt.MouseEventNotSynthesized)
                        return

                    root.sendPointerPress(mouse.x, mouse.y)
                }

                onPositionChanged: function(mouse) {
                    if (mouse.source !== Qt.MouseEventNotSynthesized)
                        return

                    if (pressed)
                        root.sendPointerMove(mouse.x, mouse.y)
                }

                onReleased: function(mouse) {
                    if (mouse.source !== Qt.MouseEventNotSynthesized)
                        return

                    root.sendPointerRelease(mouse.x, mouse.y)
                }

                onCanceled: {
                    root.sendPointerRelease(mouseX, mouseY)
                }
            }

            MultiPointTouchArea {
                anchors.fill: parent
                minimumTouchPoints: 1
                maximumTouchPoints: 1
                mouseEnabled: false
                enabled: readyForInput

                touchPoints: [
                    TouchPoint { id: tp1 }
                ]

                onPressed: function(points) {
                    if (root.touchActive || points.length <= 0)
                        return
                    root.beginTouch(points[0])
                }

                onUpdated: function(points) {
                    if (points.length <= 0)
                        return
                    root.updateTouch(points[0])
                }

                onReleased: function(points) {
                    if (points.length <= 0) {
                        root.cancelTouch()
                        return
                    }
                    root.endTouch(points[0])
                }

                onCanceled: function(points) {
                    if (points.length > 0)
                        root.endTouch(points[0])
                    else
                        root.cancelTouch()
                }
            }
        }
    }

    Connections {
        target: hasCarPlayEngine ? carPlayEngine : null

        function onErrorMessage(msg) {
            console.error("[CarPlay ERROR]", msg)
        }
    }
}