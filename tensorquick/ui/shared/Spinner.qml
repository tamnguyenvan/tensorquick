import QtQuick
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects

// Loading spinner (macOS style)
Item {
    property bool loading: false
    visible: loading
    width: 14
    height: 14
    // anchors {
    //     right: createButtonContent.left
    //     rightMargin: -10
    //     verticalCenter: parent.verticalCenter
    // }
    opacity: loading ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    // Spinner circle
    Rectangle {
        id: spinnerCircle
        anchors.fill: parent
        color: "transparent"
        border.color: "#ffffff"
        border.width: 1.5
        radius: width/2
    }

    // Spinner gradient overlay
    ConicalGradient {
        anchors.fill: parent
        angle: 270
        source: spinnerCircle
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 0.7; color: "#ffffff" }
            GradientStop { position: 0.701; color: "transparent" }
            GradientStop { position: 1.0; color: "transparent" }
        }

        RotationAnimation on rotation {
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: loading
            easing.type: Easing.Linear
        }
    }
}