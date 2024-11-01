import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import "../../shared"

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    required property bool isDarkMode
    required property color textColor

    property var currentModel: null

    // macOS styling
    color: isDarkMode ? "#28282B" : "#FFFFFF"
    radius: 10

    // macOS-style shadow
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        radius: 8
        samples: 17
        color: isDarkMode ? "#40000000" : "#20000000"
        horizontalOffset: 0
        verticalOffset: 2
    }

    Component.onCompleted: {
        currentModel = sessionSettings.currentModel
    }

    Connections {
        target: inferencePipeline

        function onCurrentModelChanged(model) {
            currentModel = model
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        clip: true

        ColumnLayout {
            width: scrollView.width
            spacing: 20  // Adjusted for macOS density

            // Header
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 20
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                spacing: 8

                Text {
                    text: "Current Model"
                    font.pixelSize: 20  // macOS standard size
                    font.weight: Font.DemiBold
                    color: textColor
                    font.family: "Inter"  // System font
                }
            }

            // Main Content Area
            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: 320
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                radius: 8
                color: isDarkMode ? "#1E1E1E" : "#F5F5F5"  // Subtle background difference

                // Empty State
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    visible: !currentModel || !currentModel.code_name
                    opacity: 0.8

                    // Image {
                    //     Layout.alignment: Qt.AlignHCenter
                    //     source: isDarkMode ? "qrc:/resources/icons/model.svg" : "qrc:/resources/icons/model-light.svg"
                    //     sourceSize: Qt.size(32, 32)
                    //     opacity: isDarkMode ? 0.7 : 0.5
                    // }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No Model Selected"
                        font.pixelSize: 15
                        font.weight: Font.Medium
                        color: textColor
                        font.family: "Inter"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Select a model from the list to begin"
                        font.pixelSize: 13
                        color: isDarkMode ? "#999999" : "#666666"
                        font.family: "Inter"
                    }
                }

                // Active Model State
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    visible: currentModel && currentModel.deployed_url ? true : false

                    // // Left side - Preview Image
                    // Rectangle {
                    //     Layout.preferredWidth: Math.min(parent.width * 0.5, 280)
                    //     Layout.preferredHeight: Math.min(parent.width * 0.5, 280)
                    //     color: isDarkMode ? "#252525" : "#FFFFFF"
                    //     radius: 6

                    //     // macOS-style inner shadow
                    //     layer.enabled: true
                    //     layer.effect: InnerShadow {
                    //         radius: 2
                    //         samples: 7
                    //         color: isDarkMode ? "#40000000" : "#20000000"
                    //         horizontalOffset: 0
                    //         verticalOffset: 1
                    //     }

                    //     Image {
                    //         anchors.fill: parent
                    //         anchors.margins: 6
                    //         source: currentModel && currentModel.preview ? currentModel.preview : ""
                    //         fillMode: Image.PreserveAspectCrop
                    //         smooth: true
                    //         mipmap: true
                    //     }
                    // }

                    // Right side - Model Information
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 16

                        MacOSGroupBox {
                            title: "Model Name"
                            content: currentModel && currentModel.name ? currentModel.name : ""
                            isDarkMode: root.isDarkMode
                            textColor: root.textColor
                        }

                        MacOSGroupBox {
                            title: "Code Name"
                            content: currentModel && currentModel.code_name ? currentModel.code_name : ""
                            isDarkMode: root.isDarkMode
                            textColor: root.textColor
                        }

                        MacOSGroupBox {
                            title: "Description"
                            content: currentModel && currentModel.description ? currentModel.description : ""
                            isDarkMode: root.isDarkMode
                            textColor: root.textColor
                        }

                        // Deployed URL with macOS-style link
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Image {
                                source: isDarkMode ? "qrc:/resources/icons/copy.svg" : "qrc:/resources/icons/copy-light.svg"
                                sourceSize: Qt.size(14, 14)
                                opacity: urlMouseArea.containsMouse ? 0.7 : 1.0

                                MouseArea {
                                    id: urlMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        clipboard.copyTextToClipboard(currentModel && currentModel.deployed_url ? currentModel.deployed_url : "")
                                    }
                                }
                            }

                            Text {
                                text: currentModel && currentModel.deployed_url ? currentModel.deployed_url : ""
                                font.pixelSize: 13
                                color: isDarkMode ? "#419CFF" : "#0066CC"
                                font.family: "Inter"
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                elide: Text.ElideMiddle
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
}
