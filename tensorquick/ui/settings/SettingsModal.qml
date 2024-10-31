import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "./content"
import "../shared"

ApplicationWindow {
    id: settingsModal
    title: "Settings"
    visible: true
    width: 1280
    height: 900
    x: (Screen.width - width) / 2
    y: 100
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // Theme properties
    property bool isDarkMode: true
    property color backgroundColor: isDarkMode ? "#28282A" : "#F5F5F7"
    property color sidebarColor: isDarkMode ? "#1D1D1F" : "#E8E8EA"
    property color contentColor: isDarkMode ? "#28282A" : "#FFFFFF"
    property color borderColor: isDarkMode ? "#3D3D3F" : "#DDDDDF"
    property color textColor: isDarkMode ? "#FFFFFF" : "#000000"
    property color secondaryTextColor: isDarkMode ? "#999999" : "#666666"
    property color hoverColor: isDarkMode ? "#35353A" : "#F0F0F2"
    property color selectedColor: isDarkMode ? "#404045" : "#E5E5E7"

    function teardown() {
        // Save settings before quit
        sessionSettings.deployedModels = modelBuilder.deployedModels
        sessionSettings.save()
        settingsModal.hide()
    }

    Rectangle {
        id: mainContainer
        anchors.fill: parent
        radius: 10
        color: backgroundColor
        border.color: borderColor
        border.width: 1
        focus: true

        // Add window shadow
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: "#40000000"
            radius: 20
            samples: 20
            horizontalOffset: 0
            verticalOffset: 0
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                teardown()
            }
        }

        // Window title bar
        Rectangle {
            id: titleBar
            height: 60
            color: "transparent"
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            DragHandler {
                onActiveChanged: if (active) {
                    settingsModal.startSystemMove()
                }
            }

            // macOS window controls
            Row {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 20
                }
                spacing: 8

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: "#FF5F57"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: settingsModal.hide()
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Settings"
                color: textColor
                font.pixelSize: 14
                font.family: "Inter"
            }
        }

        // Main content
        RowLayout {
            anchors {
                left: parent.left
                right: parent.right
                top: titleBar.bottom
                bottom: parent.bottom
                margins: 1
            }
            spacing: 0

            Sidebar {
                id: sidebar
            }

            // Content area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: contentColor

                StackLayout {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    currentIndex: sidebar.currentIndex

                    // Model
                    ContentModel {
                        isDarkMode: settingsModal.isDarkMode
                        textColor: settingsModal.textColor
                    }

                    ContentShortcut {}

                    // About
                    About {
                        isDarkMode: settingsModal.isDarkMode
                        textColor: settingsModal.textColor
                    }
                }
            }
        }
    }
}