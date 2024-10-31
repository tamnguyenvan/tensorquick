import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../shared"

Rectangle {
    id: root

    // Public properties
    property string promptText: ""
    property bool isDarkMode: false
    property alias placeholder: placeholderText.text
    property color textColor: isDarkMode ? "#FFFFFF" : "#000000"
    property alias text: promptInput.text
    signal submitted(string text)

    // Theme properties
    property color backgroundColor: isDarkMode ? "#1E1E1E" : "#FFFFFF"
    property color borderColor: isDarkMode ? "#3F3F3F" : "#E5E5E5"
    property color focusBorderColor: "#0A84FF"  // macOS accent blue
    property color placeholderColor: isDarkMode ? "#8E8E8E" : "#98989D"
    property color buttonBackgroundColor: isDarkMode ? "#0A84FF" : "#0A84FF"
    property color buttonHoverColor: isDarkMode ? "#0071E3" : "#0071E3"
    property color buttonPressColor: isDarkMode ? "#0058B6" : "#0058B6"

    // Container styling
    Layout.fillWidth: true
    height: 36
    radius: 6
    color: backgroundColor

    // Border styling with smooth transitions
    border.color: promptInput.activeFocus ? focusBorderColor : borderColor
    border.width: promptInput.activeFocus ? 2 : 1

    // Smooth transitions
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    Behavior on border.width {
        NumberAnimation { duration: 150 }
    }

    // Input shadow effect
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        color: isDarkMode ? "#00000000" : "#1A000000"
        samples: 12
        radius: 8
        verticalOffset: 1
        spread: 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 0

        // Container for TextInput to handle cursor shape
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton  // Không xử lý click events
                hoverEnabled: true
            }

            TextInput {
                id: promptInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                color: textColor
                font {
                    family: "Inter"
                    pixelSize: 13
                }
                clip: true
                selectByMouse: true

                onTextChanged: {
                    promptText = promptInput.text
                }

                // Placeholder text
                Text {
                    id: placeholderText
                    anchors.fill: parent
                    text: "Enter your prompt..."
                    color: placeholderColor
                    font {
                        family: "Inter"
                        pixelSize: 13
                    }
                    verticalAlignment: Text.AlignVCenter
                    visible: !parent.text && !parent.activeFocus
                }

                // Selection styling
                selectedTextColor: isDarkMode ? "#FFFFFF" : "#000000"
                selectionColor: Qt.rgba(buttonBackgroundColor.r,
                                      buttonBackgroundColor.g,
                                      buttonBackgroundColor.b,
                                      isDarkMode ? 0.5 : 0.3)
            }
        }

        // Create Button
        Rectangle {
            id: createButton
            Layout.fillHeight: true
            Layout.preferredWidth: createButtonContent.width + 24
            Layout.rightMargin: 4
            Layout.alignment: Qt.AlignVCenter
            color: createButtonArea.pressed ? buttonPressColor :
                   (createButtonArea.containsMouse ? buttonHoverColor : buttonBackgroundColor)
            radius: 4

            // Smooth color transition
            Behavior on color {
                ColorAnimation { duration: 100 }
            }

            // Button content
            Row {
                id: createButtonContent
                anchors.centerIn: parent
                spacing: 6

                // Button icon
                Image {
                    id: buttonIcon
                    width: 14
                    height: 14
                    source: "qrc:/resources/icons/create.svg"
                    anchors.verticalCenter: parent.verticalCenter

                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: "#FFFFFF"
                    }
                }

                // Button text
                Text {
                    text: "Create"
                    color: "#FFFFFF"
                    font {
                        family: "Inter"
                        pixelSize: 13
                        weight: Font.Medium
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Button interaction
            MouseArea {
                id: createButtonArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: submitInput()
            }
        }
    }

    // Focus effect
    Rectangle {
        id: focusHighlight
        anchors.fill: parent
        color: "transparent"
        radius: parent.radius
        border.color: focusBorderColor
        border.width: 0
        opacity: 0
        visible: promptInput.activeFocus

        // Focus glow effect
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: focusBorderColor
            samples: 15
            radius: 6
            spread: 0.2
        }

        // Focus animation states
        states: State {
            name: "focused"
            when: promptInput.activeFocus
            PropertyChanges {
                target: focusHighlight
                opacity: isDarkMode ? 0.4 : 0.3
                border.width: 2
            }
        }

        transitions: Transition {
            NumberAnimation {
                properties: "opacity,border.width"
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    // Function to handle input submission
    function submitInput() {
        if (promptInput.text.trim() !== "") {
            submitted(promptInput.text)
            return true
        }
        return false
    }
}