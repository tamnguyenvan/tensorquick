import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    id: root
    width: 28
    height: 28
    color: closeArea.containsMouse ? "#27272a" : "#2d2d2d"
    radius: width / 2

    property string iconSource: ""

    // Define the signal
    signal clicked

    Behavior on color {
        ColorAnimation {
            duration: 100
        }
    }

    Image {
        id: closeButton
        width: 16
        height: 16
        anchors.centerIn: parent
        source: iconSource
        opacity: closeArea.containsMouse ? 1 : 0.7

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }

    MouseArea {
        id: closeArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked() // Emit the signal
    }
}
