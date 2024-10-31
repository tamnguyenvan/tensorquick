import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    Layout.preferredWidth: 220
    Layout.fillHeight: true
    color: isDarkMode ? "#1E1E1E" : "#F5F5F5"

    property int currentIndex: 0

    signal createShortcutClicked()

    ListView {
        id: menuList
        anchors.fill: parent
        anchors.topMargin: 16
        spacing: 4

        model: [
            {
                "name": "Model",
                "iconSource": isDarkMode ? "qrc:/resources/icons/model.svg" : "qrc:/resources/icons/model-light.svg"
            },
            {
                "name": "Create Shortcut",
                "iconSource": isDarkMode ? "qrc:/resources/icons/shortcut.svg" : "qrc:/resources/icons/shortcut-light.svg"
            },
            {
                "name": "About",
                "iconSource": isDarkMode ? "qrc:/resources/icons/about.svg" : "qrc:/resources/icons/about-light.svg"
            }
        ]

        currentIndex: 0

        delegate: Item {
            width: menuList.width
            height: 32

            Rectangle {
                id: itemBg
                anchors {
                    fill: parent
                    leftMargin: 8
                    rightMargin: 8
                }
                radius: 6

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: {
                            if (menuList.currentIndex === index) {
                                return isDarkMode ? "#3D7EFF" : "#007AFF"
                            }
                            if (mouseArea.containsMouse) {
                                return isDarkMode ? "#2A2A2A" : "#E5E5E5"
                            }
                            return "transparent"
                        }
                    }
                    GradientStop {
                        position: 1.0
                        color: {
                            if (menuList.currentIndex === index) {
                                return isDarkMode ? "#2B66FF" : "#0066FF"
                            }
                            if (mouseArea.containsMouse) {
                                return isDarkMode ? "#2A2A2A" : "#E5E5E5"
                            }
                            return "transparent"
                        }
                    }
                }

                layer.enabled: mouseArea.containsMouse
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: isDarkMode ? "#80000000" : "#20000000"
                    radius: 8
                    samples: 17
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 8

                    Image {
                        width: 16
                        height: 16
                        source: modelData.iconSource
                        opacity: {
                            if (menuList.currentIndex === index) return 1.0
                            return isDarkMode ? 0.8 : 0.7
                        }

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: menuList.currentIndex === index ? "white" :
                                  (isDarkMode ? "#FFFFFF" : "#000000")
                            opacity: menuList.currentIndex === index ? 1.0 : 0.7
                        }
                    }

                    Text {
                        text: modelData.name
                        color: menuList.currentIndex === index ? "white" :
                               (isDarkMode ? "#FFFFFF" : "#000000")
                        opacity: menuList.currentIndex === index ? 1.0 : 0.8
                        font {
                            family: "Inter"
                            pixelSize: 13
                            // weight: menuList.currentIndex === index ? Font.Medium : Font.Regular
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                // Animations
                Behavior on gradient {
                    enabled: true
                    ColorAnimation { duration: 150 }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    menuList.currentIndex = index
                    root.currentIndex = index
                }
            }
        }
    }

    // Add bottom separator
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: isDarkMode ? "#333333" : "#E0E0E0"
    }
}