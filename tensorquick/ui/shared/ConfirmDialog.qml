import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Dialog {
    id: root
    modal: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Public properties
    property bool isDarkMode: false
    property string text: "Are you sure?"
    property string acceptText: "OK"
    property string rejectText: "Cancel"

    // Theme colors
    readonly property color backgroundColor: isDarkMode ? "#2c2c2c" : "#ffffff"
    readonly property color borderColor: isDarkMode ? "#3f3f3f" : "#e5e5e5"
    readonly property color textColor: isDarkMode ? "#ffffff" : "#000000"
    readonly property color secondaryTextColor: isDarkMode ? "#a1a1aa" : "#666666"
    readonly property color buttonBgColor: isDarkMode ? "#3a3a3a" : "#f5f5f5"
    readonly property color buttonHoverColor: isDarkMode ? "#454545" : "#eeeeee"
    readonly property color buttonPressColor: isDarkMode ? "#505050" : "#e8e8e8"
    readonly property color accentColor: isDarkMode ? "#0a84ff" : "#007aff"
    readonly property color accentHoverColor: isDarkMode ? "#1a8fff" : "#0070e8"
    readonly property color accentPressColor: isDarkMode ? "#2a9aff" : "#0064d1"

    // Private properties
    property int animationDuration: 150

    // Position the dialog in the center with some offset from top
    x: Math.round((parent.width - width) / 2)
    y: Math.round(parent.height / 4)

    // Background
    background: Item {
        Rectangle {
            id: bgRect
            anchors.fill: parent
            color: backgroundColor
            radius: 12
            border.color: borderColor
            border.width: 1
            opacity: 0.98

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12.0
                samples: 25
                color: isDarkMode ? "#80000000" : "#40000000"
            }
        }
    }

    // Content wrapper
    contentItem: Item {
        implicitWidth: 380
        implicitHeight: content.height

        // Main content column
        Column {
            id: content
            spacing: 24
            width: parent.width
            padding: 24

            // Title and message
            Column {
                width: parent.width - parent.padding * 2
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter

                // Title
                Text {
                    text: root.title
                    color: textColor
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.family: "Inter"
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                }

                // Message
                Text {
                    text: root.text
                    color: secondaryTextColor
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    font.family: "Inter"
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                }
            }

            // Buttons row
            Row {
                spacing: 8
                anchors.right: parent.right
                rightPadding: parent.padding
                layoutDirection: Qt.RightToLeft

                // Accept button
                Button {
                    id: acceptButton
                    text: root.acceptText
                    width: Math.max(100, implicitWidth + 32)
                    height: 32

                    contentItem: Text {
                        text: acceptButton.text
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.family: "Inter"
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 6
                        color: acceptButton.pressed ? accentPressColor :
                               acceptButton.hovered ? accentHoverColor :
                               accentColor

                        Behavior on color {
                            ColorAnimation { duration: animationDuration }
                        }
                    }

                    onClicked: {
                        root.accept()
                    }
                }

                // Reject button
                Button {
                    id: rejectButton
                    text: root.rejectText
                    width: Math.max(100, implicitWidth + 32)
                    height: 32

                    contentItem: Text {
                        text: rejectButton.text
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.family: "Inter"
                        color: textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 6
                        color: rejectButton.pressed ? buttonPressColor :
                               rejectButton.hovered ? buttonHoverColor :
                               buttonBgColor

                        Behavior on color {
                            ColorAnimation { duration: animationDuration }
                        }
                    }

                    onClicked: {
                        root.reject()
                    }
                }
            }
        }
    }

    // Enter transition
    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: animationDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "scale"
                from: 0.95
                to: 1.0
                duration: animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    // Exit transition
    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: animationDuration
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                property: "scale"
                from: 1.0
                to: 0.95
                duration: animationDuration
                easing.type: Easing.InCubic
            }
        }
    }

    // Dim overlay
    Overlay.modal: Rectangle {
        color: isDarkMode ? "#80000000" : "#40000000"
        opacity: 0.5

        Behavior on opacity {
            NumberAnimation {
                duration: animationDuration
            }
        }
    }
}