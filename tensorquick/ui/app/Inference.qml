import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property alias inputPrompt: inputField.promptText
    property bool isDarkMode: sessionSettings.currentTheme === "dark"

    property color textColor: isDarkMode ? "#ffffff" : "#000000"
    readonly property color backgroundColor: isDarkMode ? "#282828" : "#ffffff"
    readonly property color borderColor: isDarkMode ? "#404040" : "#d2d2d7"
    readonly property color accentColor: "#0066cc"
    readonly property color controlBackgroundColor: isDarkMode ? "#323232" : "#ffffff"
    readonly property color placeholderColor: isDarkMode ? "#98989d" : "#86868b"
    readonly property color labelColor: isDarkMode ? "#98989d" : "#86868b"
    readonly property int cornerRadius: 6

    Column {
        anchors.fill: parent
        anchors.topMargin: 12
        spacing: 12
        opacity: isInferenceMode ? 1 : 0
        visible: opacity > 0

        InputField {
            id: inputField
            // Layout.fillWidth: true
            // Layout.preferredHeight: 40
            width: parent.width
            height: 40
            isDarkMode: root.isDarkMode
            textColor: root.textColor

            onSubmitted: {
                if (inputField.promptText.trim() !== "") {
                    inferencePipeline.generateImage(inputField.promptText)
                }
            }
        }

        // Container for Image/Spinner
        Rectangle {
            id: resultContainer
            // Layout.fillWidth: true
            // Layout.preferredHeight: (hasResult || isLoading) ? 400 : 0
            width: parent.width
            height: (hasResult || isLoading) ? 400 : 0
            visible: hasResult || isLoading
            color: secondaryBackgroundColor
            radius: 8

            // Loading Spinner
            Item {
                id: spinner
                anchors.centerIn: parent
                width: 48
                height: 48
                visible: isLoading

                Rectangle {
                    id: spinnerRing
                    anchors.fill: parent
                    color: "transparent"
                    radius: width / 2
                    border.width: 3
                    border.color: controlBackgroundColor
                    visible: false
                }

                ConicalGradient {
                    anchors.fill: parent
                    source: spinnerRing
                    angle: 270
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: accentColor }
                        GradientStop { position: 0.7; color: accentColor }
                        GradientStop { position: 0.71; color: "transparent" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        running: spinner.visible
                        loops: Animation.Infinite
                        duration: 1000
                    }
                }

                Text {
                    anchors {
                        top: parent.bottom
                        topMargin: 16
                        horizontalCenter: parent.horizontalCenter
                    }
                    text: "Generating image..."
                    color: secondaryTextColor
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }

            ImageDisplay {
                id: imageDisplay
                anchors.fill: parent
                visible: hasResult && !isLoading
                isDarkMode: root.isDarkMode
                textColor: root.textColor
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }
}