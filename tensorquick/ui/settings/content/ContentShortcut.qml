import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    color: isDarkMode ? "#1E1E1E" : "#FFFFFF"

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 32
        }
        spacing: 24

        // Image {
        //     Layout.alignment: Qt.AlignHCenter
        //     source: "qrc:/resources/icons/app-icon.svg"
        //     width: 64
        //     height: 64
        // }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Create Desktop Shortcut"
            font {
                family: "Inter"
                pixelSize: 24
                weight: Font.Medium
            }
            color: isDarkMode ? "#FFFFFF" : "#000000"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 500
            Layout.preferredWidth: 500
            text: "Create a desktop shortcut for quick access to Tensor Quick. This will add an icon to your desktop that you can use to launch the application."
            font {
                family: "Inter"
                pixelSize: 14
            }
            color: isDarkMode ? "#CCCCCC" : "#666666"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.4
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            spacing: 16

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                id: createButton
                Layout.preferredWidth: 200
                Layout.preferredHeight: 36
                radius: 8

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: {
                            if (createButtonArea.pressed)
                                return isDarkMode ? "#2B66FF" : "#0055D4"
                            if (createButtonArea.containsMouse)
                                return isDarkMode ? "#3D7EFF" : "#007AFF"
                            return isDarkMode ? "#0066FF" : "#0066FF"
                        }
                    }
                    GradientStop {
                        position: 1.0
                        color: {
                            if (createButtonArea.pressed)
                                return isDarkMode ? "#2152CC" : "#004BB8"
                            if (createButtonArea.containsMouse)
                                return isDarkMode ? "#3670FF" : "#0062F0"
                            return isDarkMode ? "#0052CC" : "#0052CC"
                        }
                    }
                }

                // Shadow effect
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: isDarkMode ? "#40000000" : "#20000000"
                    radius: createButtonArea.containsMouse ? 8 : 4
                    samples: 17
                }

                // Button content
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Image {
                        source: isDarkMode ? "qrc:/resources/icons/shortcut.svg" : "qrc:/resources/icons/shortcut-light.svg"
                        width: 16
                        height: 16
                        Layout.alignment: Qt.AlignVCenter

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: "#FFFFFF"
                        }
                    }

                    Text {
                        text: "Create Shortcut"
                        color: "#FFFFFF"
                        font {
                            family: "Inter"
                            pixelSize: 14
                            weight: Font.Medium
                        }
                    }
                }

                // Button interactions
                MouseArea {
                    id: createButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sessionSettings.createShortcut()
                        successMessage.visible = true
                        successTimer.start()
                    }
                }

                // Smooth animations
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                }
            }

            // Success message
            Rectangle {
                id: successMessage
                visible: false
                Layout.preferredWidth: 300
                Layout.preferredHeight: 36
                radius: 8
                color: isDarkMode ? "#1A3D1A" : "#E6F4E6"
                border.color: isDarkMode ? "#2E5C2E" : "#A3D9A3"
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Image {
                        source: "qrc:/resources/icons/check.svg"
                        width: 16
                        height: 16
                        Layout.alignment: Qt.AlignVCenter

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: isDarkMode ? "#4CAF50" : "#2E7D32"
                        }
                    }

                    Text {
                        text: "Shortcut created successfully!"
                        color: isDarkMode ? "#4CAF50" : "#2E7D32"
                        font {
                            family: "Inter"
                            pixelSize: 13
                        }
                    }
                }

                Timer {
                    id: successTimer
                    interval: 3000
                    onTriggered: successMessage.visible = false
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }
        }
    }
}