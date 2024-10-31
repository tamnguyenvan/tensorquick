import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Dialogs

Rectangle {
    id: imageDisplay
    Layout.fillWidth: true
    Layout.preferredHeight: 500

    // Properties
    property bool isDarkMode: true
    property string imagePath: ""
    property alias imageSource: displayedImage.source
    property color textColor: "#000000"

    // Theme colors
    readonly property color backgroundColor: isDarkMode ? "#1e1e1e" : "#ffffff"
    readonly property color borderColor: isDarkMode ? "#3f3f3f" : "#e5e5e5"
    readonly property color buttonHoverColor: isDarkMode ? "#404040" : "#f0f0f0"
    readonly property color toolbarColor: isDarkMode ? Qt.darker(backgroundColor, 1.1) : Qt.lighter(backgroundColor, 1.02)

    // Tooltip theme colors
    readonly property color tooltipBackground: isDarkMode ? "#18181b" : "#ffffff"
    readonly property color tooltipBorder: isDarkMode ? "#27272a" : "#e5e5e5"
    readonly property color tooltipText: isDarkMode ? "#ffffff" : "#18181b"
    readonly property color tooltipShadow: isDarkMode ? "#00000060" : "#00000020"

    color: backgroundColor

    Connections {
        target: inferencePipeline

        function onGenerationCompleted(success, resultImagePath, error_message) {
            if (success) {
                imagePath = resultImagePath
            }
        }
    }

    // macOS style shadow
    MultiEffect {
        source: parent
        anchors.fill: parent
        shadowEnabled: true
        shadowColor: isDarkMode ? "#00000060" : "#00000040"
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 2
        shadowBlur: 10
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // Image container
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: 8
            border.color: borderColor
            border.width: 1

            Image {
                id: displayedImage
                anchors.fill: parent
                anchors.margins: 1
                fillMode: Image.PreserveAspectFit
                source: imagePath
                cache: false

                // Fade in animation
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                Component.onCompleted: opacity = 1
            }
        }

        // Toolbar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: toolbarColor
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                // Action buttons
                Row {
                    spacing: 8
                    Layout.alignment: Qt.AlignLeft

                    Button {
                        icon.source: isDarkMode ? "qrc:/resources/icons/copy.svg" : "qrc:/resources/icons/copy-light.svg"
                        flat: true
                        implicitWidth: 32
                        implicitHeight: 32

                        background: Rectangle {
                            color: parent.hovered ? buttonHoverColor : "transparent"
                            radius: 4
                        }

                        MouseArea {
                            id: copyArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (inferencePipeline.imagePath !== "") {
                                    inferencePipeline.copyImageToClipboard()
                                    copySuccessToolTip.show()
                                }
                            }
                        }

                        // Inside Button for Copy
                        ToolTip {
                            id: copyHoverToolTip
                            visible: copyArea.containsMouse && !copySuccessToolTip.visible
                            delay: 400
                            timeout: 3000

                            background: Rectangle {
                                color: tooltipBackground
                                radius: 6
                                border.color: tooltipBorder
                                border.width: 1

                                MultiEffect {
                                    source: parent
                                    anchors.fill: parent
                                    shadowEnabled: true
                                    shadowColor: tooltipShadow
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 2
                                    shadowBlur: 8
                                }
                            }

                            contentItem: Text {
                                text: "Copy to clipboard"
                                color: tooltipText
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }
                        }

                        // Success Tooltip
                        ToolTip {
                            id: copySuccessToolTip
                            visible: false
                            timeout: 2000
                            y: parent.height + 8

                            function show() {
                                visible = true
                            }

                            background: Rectangle {
                                color: tooltipBackground
                                radius: 6
                                border.color: tooltipBorder
                                border.width: 1

                                MultiEffect {
                                    source: parent
                                    anchors.fill: parent
                                    shadowEnabled: true
                                    shadowColor: tooltipShadow
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 2
                                    shadowBlur: 8
                                }
                            }

                            contentItem: RowLayout {
                                spacing: 6

                                Image {
                                    Layout.preferredWidth: 14
                                    Layout.preferredHeight: 14
                                    source: "qrc:/resources/icons/check.svg"
                                }

                                Text {
                                    text: "Copied to clipboard"
                                    color: tooltipText
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    Layout.leftMargin: 2
                                }

                                Layout.leftMargin: 8
                                Layout.rightMargin: 8
                                Layout.topMargin: 6
                                Layout.bottomMargin: 6
                            }

                            enter: Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    from: 0.0
                                    to: 1.0
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }

                            exit: Transition {
                                NumberAnimation {
                                    property: "opacity"
                                    from: 1.0
                                    to: 0.0
                                    duration: 150
                                    easing.type: Easing.InCubic
                                }
                            }
                        }
                    }

                    Button {
                        icon.source: isDarkMode ? "qrc:/resources/icons/save.svg" : "qrc:/resources/icons/save-light.svg"
                        flat: true
                        implicitWidth: 32
                        implicitHeight: 32

                        background: Rectangle {
                            color: parent.hovered ? buttonHoverColor : "transparent"
                            radius: 4
                        }

                        MouseArea {
                            id: saveArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (inferencePipeline.imagePath !== "") {
                                    inferencePipeline.saveImage()
                                }
                            }
                        }

                        // Save button tooltip
                        ToolTip {
                            visible: saveArea.containsMouse
                            delay: 400
                            timeout: 3000

                            background: Rectangle {
                                color: tooltipBackground
                                radius: 6
                                border.color: tooltipBorder
                                border.width: 1

                                MultiEffect {
                                    source: parent
                                    anchors.fill: parent
                                    shadowEnabled: true
                                    shadowColor: tooltipShadow
                                    shadowHorizontalOffset: 0
                                    shadowVerticalOffset: 2
                                    shadowBlur: 8
                                }
                            }

                            contentItem: Text {
                                text: "Save and show image"
                                color: tooltipText
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }
                        }
                    }
                }
            }
        }
    }
}