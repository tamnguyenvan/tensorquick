import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects

Page {
    id: root
    required property bool isDarkMode
    required property color textColor

    background: Rectangle {
        color: isDarkMode ? "#28282A" : "#F5F5F7"
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width
            spacing: 0

            // Header
            Pane {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                padding: 30
                background: Rectangle {
                    color: isDarkMode ? "#1D1D1F" : "#FFFFFF"

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 0.4
                        blurMax: 24
                        shadowEnabled: true
                        shadowColor: isDarkMode ? "#000000" : "#20000000"
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 1
                        shadowBlur: 0.5
                        opacity: isDarkMode ? 0.7 : 0.5
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    Image {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64
                        source: "qrc:/resources/icons/app-icon.svg"
                    }

                    Label {
                        text: "Tensor Quick"
                        font {
                            pixelSize: 24
                            weight: Font.Medium
                            family: "Inter"
                        }
                        color: textColor
                    }

                    Label {
                        text: "Version " + defaultSettings.version
                        font {
                            pixelSize: 13
                            family: "Inter"
                        }
                        color: isDarkMode ? "#999999" : "#666666"
                    }
                }
            }

            // Content
            Pane {
                Layout.fillWidth: true
                Layout.fillHeight: true
                padding: 30
                background: Rectangle {
                    color: "transparent"
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 24

                    // Description
                    Label {
                        Layout.fillWidth: true
                        text: "Tensor Quick is a free, open-source, and multi-platform desktop application that helps you train and use AI models easily. It has a minimalist graphical interface, so you can use AI without technical skills."
                        font {
                            pixelSize: 13
                            family: "Inter"
                        }
                        color: isDarkMode ? "#999999" : "#666666"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.5
                    }

                    // Info Cards
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 20
                        rowSpacing: 20

                        Repeater {
                            model: [{
                                    "title": "Created by",
                                    "heading": "Tam Nguyen",
                                    "subtitle": "A guy who is enthusiastic about AI."
                                }, {
                                    "title": "License",
                                    "heading": "Apache License 2.0",
                                    "subtitle": "Copyright © " + (new Date()).getFullYear() + " Tam Nguyen"
                                }]

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                color: isDarkMode ? "#1D1D1F" : "#FFFFFF"
                                radius: 10
                                border.width: 1
                                border.color: isDarkMode ? "#3D3D3F" : "#E5E5E7"

                                ColumnLayout {
                                    anchors {
                                        fill: parent
                                        margins: 16
                                    }
                                    spacing: 8

                                    Label {
                                        text: modelData.title
                                        font {
                                            pixelSize: 12
                                            family: "Inter"
                                        }
                                        color: isDarkMode ? "#999999" : "#666666"
                                    }

                                    Label {
                                        text: modelData.heading
                                        font {
                                            pixelSize: 14
                                            weight: Font.Medium
                                            family: "Inter"
                                        }
                                        color: textColor
                                    }

                                    Label {
                                        text: modelData.subtitle
                                        font {
                                            pixelSize: 12
                                            family: "Inter"
                                        }
                                        color: isDarkMode ? "#999999" : "#666666"
                                    }
                                }
                            }
                        }
                    }

                    // Links
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 16
                        spacing: 24
                        Layout.alignment: Qt.AlignHCenter

                        Repeater {
                            model: [{
                                    "title": "Documentation",
                                    "url": "https://github.com/tamnguyenvan/tensorquick"
                                }, {
                                    "title": "GitHub",
                                    "url": "https://github.com/tamnguyenvan/tensorquick"
                                }, {
                                    "title": "Website",
                                    "url": "https://github.com/tamnguyenvan/tensorquick"
                                }]

                            Rectangle {
                                color: "transparent"
                                height: 28
                                width: linkText.width + 20

                                Label {
                                    id: linkText
                                    anchors.centerIn: parent
                                    text: modelData.title
                                    font {
                                        pixelSize: 13
                                        family: "Inter"
                                    }
                                    color: linkArea.pressed ?
                                          (isDarkMode ? "#4F8CE8" : "#0055D4") :
                                          linkArea.containsMouse ?
                                          (isDarkMode ? "#5F9CF8" : "#0066FF") :
                                          (isDarkMode ? "#6EA8FF" : "#007AFF")
                                }

                                MouseArea {
                                    id: linkArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Qt.openUrlExternally(modelData.url)
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}