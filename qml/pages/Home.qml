import QtQuick 6.8
import QtQuick3D 6.8
import QtQuick3D.AssetUtils
import Rx8_HeadUnit

HomeForm {
    id: root

    // ── Rotation state ────────────────────────────────────────────────────────
    property real _yaw: 25
    property real _pitch: -8
    property real _dragStartX: 0
    property real _dragStartY: 0
    property real _baseYaw: 0
    property real _basePitch: 0

    // ── 3D scene ──────────────────────────────────────────────────────────────
    View3D {
        id: view3D
        parent: root.view3DContainerItem
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "transparent"
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
            temporalAAEnabled: true
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 150, 700)
            eulerRotation: Qt.vector3d(-10, 0, 0)
            fieldOfView: 42
        }

        DirectionalLight {
            eulerRotation: Qt.vector3d(-30, -20, 0)
            brightness: 1.6
            color: "#ffffff"
        }

        DirectionalLight {
            eulerRotation: Qt.vector3d(15, 160, 0)
            brightness: 0.5
            color: Theme.accent
        }

        DirectionalLight {
            eulerRotation: Qt.vector3d(80, 0, 0)
            brightness: 0.2
            color: "#ffffff"
        }

        Node {
            id: carNode
            position: Qt.vector3d(90, 0, 0)
            scale: Qt.vector3d(1, 1, 1)
            eulerRotation: Qt.vector3d(root._pitch, root._yaw, 0)

            RuntimeLoader {
                id: carModel
                source: Qt.resolvedUrl("../../assets/car/Mazda_RX8.glb")
                position: Qt.vector3d(
                    -(bounds.minimum.x + bounds.maximum.x) * 0.5,
                    -(bounds.minimum.y + bounds.maximum.y) * 0.5,
                    -(bounds.minimum.z + bounds.maximum.z) * 0.5
                )
            }
        }
    }

    // ── Drag-to-rotate interaction ────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent

        onPressed: function(mouse) {
            root._dragStartX = mouse.x
            root._dragStartY = mouse.y
            root._baseYaw    = root._yaw
            root._basePitch  = root._pitch
        }

        onPositionChanged: function(mouse) {
            if (!pressed) return
            root._yaw   = root._baseYaw + (mouse.x - root._dragStartX) * 0.4
            root._pitch = Math.max(-25, Math.min(5,
                root._basePitch - (mouse.y - root._dragStartY) * 0.25))
        }
    }
}
