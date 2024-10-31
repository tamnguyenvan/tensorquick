import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    // anchors.fill: parent
    width: parent.width
    height: parent.height - 1
    color: "transparent"

    property bool isDarkMode: sessionSettings.currentTheme === "dark"

    // macOS colors
    property color textColor: isDarkMode ? "#ffffff" : "#000000"
    readonly property var gpuOptions: ["H100", "A100-80GB", "A100-40GB", "A10G", "L4", "T4"]
    readonly property color backgroundColor: isDarkMode ? "#282828" : "#ffffff"
    readonly property color borderColor: isDarkMode ? "#404040" : "#d2d2d7"
    readonly property color accentColor: "#0066cc"
    readonly property color controlBackgroundColor: isDarkMode ? "#323232" : "#f2f2f2"
    readonly property color placeholderColor: isDarkMode ? "#98989d" : "#86868b"
    readonly property color labelColor: isDarkMode ? "#98989d" : "#86868b"
    readonly property int cornerRadius: 8

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        Item {
            width: scrollView.width
            implicitHeight: contentLayout.implicitHeight

            ColumnLayout {
                id: contentLayout
                Layout.alignment: Qt.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                // Set a maximum width for the form
                width: Math.min(parent.width - 48, 800)

                spacing: 32

                // Header
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: "Create Training Job"
                        font.pixelSize: 24
                        font.weight: Font.Medium
                        color: textColor
                    }

                    Text {
                        text: "Configure your model training parameters"
                        font.pixelSize: 14
                        color: labelColor
                    }
                }

                // Form Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    columnSpacing: 24
                    rowSpacing: 24
                    columns: 2

                    // App Name
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "App Name*"
                            color: labelColor
                            font.pixelSize: 13
                        }

                        TextField {
                            id: appNameField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            placeholderText: "Enter app name"
                            placeholderTextColor: placeholderColor
                            color: textColor
                            font.pixelSize: 14
                            background: Rectangle {
                                color: controlBackgroundColor
                                border.color: appNameField.activeFocus ? accentColor : borderColor
                                border.width: appNameField.activeFocus ? 2 : 1
                                radius: cornerRadius
                            }
                            selectByMouse: true
                        }
                    }

                    // Code Name
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Code Name*"
                            color: labelColor
                            font.pixelSize: 13
                        }

                        TextField {
                            id: codeNameField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            placeholderText: "Enter code name"
                            placeholderTextColor: placeholderColor
                            color: textColor
                            font.pixelSize: 14
                            background: Rectangle {
                                color: controlBackgroundColor
                                border.color: codeNameField.activeFocus ? accentColor : borderColor
                                border.width: codeNameField.activeFocus ? 2 : 1
                                radius: cornerRadius
                            }
                            selectByMouse: true
                        }
                    }

                    // GPU Type
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "GPU Type"
                            color: labelColor
                            font.pixelSize: 13
                        }

                        ComboBox {
                            id: gpuTypeCombo
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            model: gpuOptions
                            currentIndex: 0
                            font.pixelSize: 14

                            background: Rectangle {
                                color: controlBackgroundColor
                                border.color: parent.down || parent.pressed ? accentColor : borderColor
                                border.width: parent.down || parent.pressed ? 2 : 1
                                radius: cornerRadius
                            }

                            contentItem: Text {
                                leftPadding: 8
                                rightPadding: gpuTypeCombo.indicator.width + 8
                                text: gpuTypeCombo.displayText
                                font: gpuTypeCombo.font
                                color: textColor
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            indicator: Image {
                                x: gpuTypeCombo.width - width - 8
                                y: gpuTypeCombo.height / 2 - height / 2
                                width: 12
                                height: 12
                                source: isDarkMode ? "qrc:/resources/icons/dropdown.svg" : "qrc:/resources/icons/dropdown-light.svg"
                            }

                            popup: Popup {
                                y: gpuTypeCombo.height + 4
                                width: gpuTypeCombo.width
                                padding: 1

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: gpuTypeCombo.popup.visible ? gpuTypeCombo.delegateModel : null
                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }

                                background: Rectangle {
                                    color: controlBackgroundColor
                                    border.color: borderColor
                                    border.width: 1
                                    radius: cornerRadius

                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        color: isDarkMode ? "#80000000" : "#20000000"
                                        radius: 4
                                        samples: 9
                                    }
                                }
                            }

                            delegate: ItemDelegate {
                                width: gpuTypeCombo.width
                                height: 32
                                padding: 8

                                contentItem: Text {
                                    text: modelData
                                    color: textColor
                                    font: gpuTypeCombo.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: parent.highlighted ? (isDarkMode ? "#404040" : "#f5f5f5") : "transparent"
                                }

                                highlighted: gpuTypeCombo.highlightedIndex === index
                            }
                        }
                    }

                    // Output folder
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Output folder"
                            color: labelColor
                            font.pixelSize: 13
                        }

                        TextField {
                            id: outputField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            placeholderText: "Enter gid of output folder"
                            placeholderTextColor: placeholderColor
                            color: textColor
                            font.pixelSize: 14
                            background: Rectangle {
                                color: controlBackgroundColor
                                border.color: outputField.activeFocus ? accentColor : borderColor
                                border.width: outputField.activeFocus ? 2 : 1
                                radius: cornerRadius
                            }
                            selectByMouse: true
                        }
                    }
                }

                // Full width items
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    // Training Script
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Training Script*"
                            color: labelColor
                            font.pixelSize: 13
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            TextField {
                                id: trainingScriptField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                placeholderText: "Select training script"
                                placeholderTextColor: placeholderColor
                                color: textColor
                                font.pixelSize: 14
                                background: Rectangle {
                                    color: controlBackgroundColor
                                    border.color: trainingScriptField.activeFocus ? accentColor : borderColor
                                    border.width: trainingScriptField.activeFocus ? 2 : 1
                                    radius: cornerRadius
                                }
                                selectByMouse: true
                                readOnly: true
                            }

                            Button {
                                text: "Choose"
                                Layout.preferredHeight: 32
                                Layout.preferredWidth: 100
                                font.pixelSize: 13
                                font.weight: Font.Medium

                                background: Rectangle {
                                    color: parent.down ? Qt.darker(controlBackgroundColor, 1.1) :
                                        parent.hovered ? Qt.darker(controlBackgroundColor, 1.05) :
                                        controlBackgroundColor
                                    border.color: parent.down ? accentColor : borderColor
                                    border.width: parent.down ? 2 : 1
                                    radius: cornerRadius

                                    Behavior on color {
                                        ColorAnimation { duration: 100 }
                                    }
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: textColor
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: fileDialog.open()
                            }
                        }
                    }

                    // Training data
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "Training data*"
                            color: labelColor
                            font.pixelSize: 13
                        }

                        TextField {
                            id: dataField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            placeholderText: "Enter gid of training file"
                            placeholderTextColor: placeholderColor
                            color: textColor
                            font.pixelSize: 14
                            background: Rectangle {
                                color: controlBackgroundColor
                                border.color: dataField.activeFocus ? accentColor : borderColor
                                border.width: dataField.activeFocus ? 2 : 1
                                radius: cornerRadius
                            }
                            selectByMouse: true
                        }
                    }
                }

                // Submit Button Section
                Item {
                    Layout.fillWidth: true
                    // Layout.topMargin: 8
                    Layout.preferredHeight: 48

                    Button {
                        anchors.centerIn: parent
                        text: "Create Job"
                        width: 140
                        height: 36
                        font.pixelSize: 13
                        font.weight: Font.Medium

                        background: Rectangle {
                            color: parent.down ? Qt.darker(accentColor, 1.2) :
                                parent.hovered ? Qt.darker(accentColor, 1.1) :
                                accentColor
                            radius: cornerRadius

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select Training Script"
        onAccepted: {
            trainingScriptField.text = fileDialog.selectedFile
        }
    }
}