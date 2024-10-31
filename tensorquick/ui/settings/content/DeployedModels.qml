import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    required property bool isDarkMode
    required property color textColor

    signal modelSelected()

    // macOS styling
    color: isDarkMode ? "#28282B" : "#FFFFFF"
    radius: 10

    property var deployedModels: []
    property var selectedModel: { "model": {}, "index": -1 }

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

    function setSelectedModel(models, currentModel) {
        // Case 1: Empty models array
        if (!models || models.length === 0) {
            console.log("Case 1: Empty models")
            selectedModel = { model: {}, index: -1 }
            return
        }

        // Case 2: Models exist but currentModel is null
        if (!currentModel) {
            console.log("Case 2: Current model is null")
            selectedModel = { model: models[0], index: 0 }
            return
        }

        // Case 3: Search for matching model
        if (currentModel.code_name) {
            for (let i = 0; i < models.length; i++) {
                if (models[i].code_name === currentModel.code_name) {
                    console.log("Case 3: Found matching model:", models[i].code_name)
                    selectedModel = {
                        model: models[i],
                        index: i
                    }
                    return
                }
            }
        }

        // Case 4: No match found
        console.log("Case 4: No match found")
        selectedModel = { model: models[0], index: 0 }
    }

    Connections {
        target: modelBuilder

        function onDeployedModelsChanged(models) {
            deployedModels = models
            setSelectedModel(models, sessionSettings.currentModel)
        }
    }

    onSelectedModelChanged: function() {
        inferencePipeline.currentModel = selectedModel.model
        sessionSettings.currentModel = selectedModel.model
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        // Header with macOS styling
        Text {
            text: "Deployments"
            font.pixelSize: 20
            font.weight: Font.DemiBold
            color: textColor
            font.family: "Inter"
        }

        // Grid View with macOS styling
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            clip: true

            GridView {
                id: modelGrid
                width: parent.width
                cellWidth: width
                cellHeight: 64  // Slightly smaller for macOS density
                model: deployedModels

                delegate: Item {
                    id: delegateItem
                    width: modelGrid.width - 16
                    height: 52

                    // Model card with macOS styling
                    Rectangle {
                        id: modelCard
                        anchors.fill: parent
                        anchors.margins: 4
                        color: isDarkMode ?
                               (selectedModel.index === index ? "#3A3A3C" : "#2C2C2E") :
                               (selectedModel.index === index ? "#F5F5F7" : "#FFFFFF")
                        radius: 6

                        // macOS-style selection indicator
                        Rectangle {
                            visible: selectedModel.index === index
                            width: 3
                            height: parent.height - 16
                            radius: 1.5
                            color: isDarkMode ? "#0A84FF" : "#007AFF"  // macOS blue
                            anchors {
                                left: parent.left
                                leftMargin: 4
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        // Content layout
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // Model name with system font
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 2
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData && modelData.code_name ? modelData.code_name : ""
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.family: "Inter"
                                    color: textColor
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData && modelData.gpu_type ? modelData.gpu_type : ""
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.family: "Inter"
                                    color: textColor
                                }
                            }

                            // Select button with macOS styling
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 90
                                    height: 28
                                    color: isDarkMode ?
                                        (buttonHover.hovered ? "#3A3A3C" : "#323234") :
                                        (buttonHover.hovered ? "#F5F5F7" : "#FFFFFF")
                                    radius: 6

                                    // Button border
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: "transparent"
                                        border.width: 1
                                        border.color: isDarkMode ?
                                                    (selectedModel.index === index ? "#0A84FF" : "#48484A") :
                                                    (selectedModel.index === index ? "#007AFF" : "#E5E5E5")
                                    }

                                    HoverHandler {
                                        id: buttonHover
                                    }

                                    // Button text
                                    Text {
                                        anchors.centerIn: parent
                                        text: selectedModel.index === index ? "Selected" : "Select"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.family: "Inter"
                                        color: selectedModel.index === index ?
                                            (isDarkMode ? "#0A84FF" : "#007AFF") :
                                            textColor
                                    }
                                    MouseArea {
                                        id: buttonArea
                                        anchors.fill: parent
                                        onClicked: {
                                            selectedModel = { model: modelData, index: index }
                                        }
                                    }
                                }
                            }

                            // New Trash Icon Button
                            Item {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 28

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 28
                                    height: 28
                                    color: trashButtonHover.hovered ?
                                        (isDarkMode ? "#3A3A3C" : "#F5F5F7") :
                                        "transparent"
                                    radius: 6

                                    // Icon
                                    Image {
                                        anchors.centerIn: parent
                                        width: 16
                                        height: 16
                                        source: "qrc:/resources/icons/trash.svg"
                                        sourceSize: Qt.size(16, 16)
                                        opacity: trashButtonHover.hovered ? 1.0 : 0.8
                                    }

                                    // Hover effect
                                    HoverHandler {
                                        id: trashButtonHover
                                    }

                                    // macOS-style press effect
                                    Rectangle {
                                        id: trashPressEffect
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: isDarkMode ? "#FFFFFF" : "#000000"
                                        opacity: 0

                                        states: State {
                                            name: "pressed"
                                            when: trashButtonArea.pressed
                                            PropertyChanges {
                                                target: trashPressEffect
                                                opacity: isDarkMode ? 0.1 : 0.05
                                            }
                                        }

                                        transitions: Transition {
                                            to: "*"
                                            NumberAnimation {
                                                property: "opacity"
                                                duration: 100
                                                easing.type: Easing.OutQuad
                                            }
                                        }

                                        MouseArea {
                                            id: trashButtonArea
                                            anchors.fill: parent
                                            onClicked: {
                                                modelBuilder.stopApp(modelData)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}