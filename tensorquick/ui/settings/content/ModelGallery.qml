import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../shared"

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    required property bool isDarkMode
    required property color textColor

    color: isDarkMode ? "#28282B" : "#FFFFFF"
    radius: 10

    property var availableModels: []
    property var deployedModelCodeNames: []
    property int selectedModelIndex: -1
    property var selectedModel: null
    property int deployingModelIndex: -1

    readonly property var gpuOptions: ["H100", "A100-40GB", "A100-80GB", "A10G", "L4", "T4"]

    Rectangle {
        id: shadowSource
        anchors.fill: parent
        color: "transparent"
        visible: false
        radius: parent.radius
    }

    DropShadow {
        anchors.fill: shadowSource
        source: shadowSource
        transparentBorder: true
        radius: 8
        samples: 17
        color: isDarkMode ? "#40000000" : "#20000000"
        horizontalOffset: 0
        verticalOffset: 2
    }

    Connections {
        target: sessionSettings
        function onAvailableModelsChanged(models) {
            availableModels = availableModels.concat(models)
        }

        function onDeployedModelsChanged(models) {
            var codeNames = []
            for (const model of models) {
                if (model && model.code_name) {
                    codeNames.push(model.code_name)
                }
            }
            deployedModelCodeNames = codeNames
        }
    }

    Connections {
        target: defaultSettings
        function onAvailableModelsChanged(models) {
            availableModels = availableModels.concat(models)
        }
    }

    Connections {
        target: modelBuilder

        function onDeployedChanged(deployed) {
            if (deployed) {
                deployingModelIndex = -1
            }
        }

        function onDeployedModelsChanged(models) {
            sessionSettings.deployedModels = models
            sessionSettings.save()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "Model Gallery"
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: textColor
                font.family: "Inter"
                renderType: Text.NativeRendering
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            clip: true

            GridView {
                id: modelGrid
                width: parent.width
                cellWidth: width / 3
                cellHeight: 420  // Increased height to accommodate ComboBox
                model: availableModels

                delegate: Item {
                    id: delegateItem
                    width: modelGrid.cellWidth
                    height: modelGrid.cellHeight

                    // Shadow
                    Rectangle {
                        id: cardShadowSource
                        anchors.centerIn: parent
                        width: modelCard.width
                        height: modelCard.height
                        radius: 8
                        visible: false
                    }

                    DropShadow {
                        anchors.fill: cardShadowSource
                        source: cardShadowSource
                        transparentBorder: true
                        radius: 4
                        samples: 9
                        color: isDarkMode ? "#40000000" : "#20000000"
                        horizontalOffset: 0
                        verticalOffset: 1
                    }

                    Rectangle {
                        id: modelCard
                        anchors.centerIn: parent
                        width: parent.width - 16
                        height: parent.height - 16
                        color: isDarkMode ? "#323234" : "#FFFFFF"
                        radius: 8

                        // Border
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: "transparent"
                            border.width: 1
                            border.color: isDarkMode ?
                                        (selectedModelIndex === index ? "#0A84FF" : "#48484A") :
                                        (selectedModelIndex === index ? "#007AFF" : "#E5E5E5")
                        }

                        HoverHandler {
                            id: cardHoverHandler
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                selectedModelIndex = index
                                selectedModel = modelData
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 180
                                color: isDarkMode ? "#28282B" : "#F5F5F7"
                                radius: 6

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: modelData && modelData.preview ? modelData.preview : "qrc:/resources/images/model-preview-placeholder.png"
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    mipmap: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: cardHoverHandler.hovered ?
                                        (isDarkMode ? "#20FFFFFF" : "#10000000") :
                                        "transparent"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: textColor
                                font.family: "Inter"
                                renderType: Text.NativeRendering
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.description
                                font.pixelSize: 13
                                color: isDarkMode ? "#999999" : "#666666"
                                font.family: "Inter"
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                renderType: Text.NativeRendering
                            }

                            // Device Selection ComboBox
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                color: isDarkMode ? "#28282B" : "#F5F5F7"
                                radius: 6
                                border.width: gpuTypeCombox.pressed ? 2 : 1
                                border.color: gpuTypeCombox.pressed ?
                                            (isDarkMode ? "#0A84FF" : "#007AFF") :
                                            (isDarkMode ? "#48484A" : "#E5E5E5")

                                ComboBox {
                                    id: gpuTypeCombox
                                    anchors.fill: parent
                                    anchors.margins: 1

                                    model: gpuOptions
                                    currentIndex: modelData.gpu_type ? gpuOptions.indexOf(modelData.gpu_type) : 0

                                    background: Rectangle {
                                        color: "transparent"
                                        radius: 6
                                    }

                                    contentItem: Text {
                                        leftPadding: 12
                                        text: gpuTypeCombox.displayText
                                        font.pixelSize: 13
                                        font.family: "Inter"
                                        color: isDarkMode ? "#FFFFFF" : "#000000"
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    indicator: Image {
                                        x: gpuTypeCombox.width - width - 8
                                        y: gpuTypeCombox.height / 2 - height / 2
                                        width: 12
                                        height: 12
                                        source: isDarkMode ? "qrc:/resources/icons/dropdown.svg" : "qrc:/resources/icons/dropdown-light.svg"
                                    }

                                    popup: Popup {
                                        y: gpuTypeCombox.height + 4
                                        width: gpuTypeCombox.width
                                        padding: 1

                                        background: Rectangle {
                                            color: isDarkMode ? "#323234" : "#FFFFFF"
                                            radius: 6
                                            border.width: 1
                                            border.color: isDarkMode ? "#48484A" : "#E5E5E5"

                                            layer.enabled: true
                                            layer.effect: DropShadow {
                                                transparentBorder: true
                                                radius: 8
                                                samples: 17
                                                color: isDarkMode ? "#80000000" : "#40000000"
                                                horizontalOffset: 0
                                                verticalOffset: 4
                                            }
                                        }

                                        contentItem: ListView {
                                            clip: true
                                            implicitHeight: contentHeight
                                            model: gpuTypeCombox.popup.visible ? gpuTypeCombox.delegateModel : null

                                            ScrollIndicator.vertical: ScrollIndicator {}
                                        }
                                    }

                                    delegate: ItemDelegate {
                                        width: gpuTypeCombox.width
                                        height: 32

                                        contentItem: Text {
                                            text: modelData
                                            font.pixelSize: 13
                                            font.family: "Inter"
                                            color: isDarkMode ? "#FFFFFF" : "#000000"
                                            verticalAlignment: Text.AlignVCenter
                                            leftPadding: 12
                                        }

                                        background: Rectangle {
                                            color: highlighted ?
                                                (isDarkMode ? "#0A84FF" : "#007AFF") :
                                                "transparent"
                                        }
                                    }
                                }
                            }

                            // Deploy button
                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8
                                // visible: sessionSettings.modelExists(modelData)
                                visible: modelData && modelData.code_name && deployedModelCodeNames.includes(modelData.code_name)

                                // Deployed badge
                                Rectangle {
                                    width: deployedText.width + 16
                                    height: 24
                                    radius: 12
                                    color: isDarkMode ? "#1C7D4D" : "#E3F9ED"

                                    Text {
                                        id: deployedText
                                        anchors.centerIn: parent
                                        text: "Deployed"
                                        font.pixelSize: 12
                                        font.family: "Inter"
                                        font.weight: Font.Medium
                                        color: isDarkMode ? "#FFFFFF" : "#1C7D4D"
                                        renderType: Text.NativeRendering
                                    }
                                }

                                // Redeploy button
                                Rectangle {
                                    width: 32
                                    height: 24
                                    radius: 6
                                    color: redeployHover.hovered ?
                                        (isDarkMode ? "#1F8FFF" : "#1984FF") :
                                        (isDarkMode ? "#0A84FF" : "#007AFF")

                                    // Animation cho hover
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    // Disabled state during deploying
                                    opacity: deployingModelIndex === index ? 0.8 : 1
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 150
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    HoverHandler {
                                        id: redeployHover
                                        enabled: deployingModelIndex !== index
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: {
                                            if (deployingModelIndex === index) {
                                                return Qt.ForbiddenCursor
                                            }
                                            return redeployHover.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        }
                                        enabled: deployingModelIndex !== index

                                        onClicked: {
                                            var dataDict = {
                                                "name": modelData.name,
                                                "code_name": modelData.code_name,
                                                "gpu_type": gpuTypeCombox.currentText.trim(),
                                                "description": modelData.description,
                                                "preview": modelData.preview
                                            }
                                            modelBuilder.deploy(dataDict)
                                            deployingModelIndex = index
                                        }
                                    }

                                    // Icon
                                    Item {
                                        anchors.fill: parent

                                        Image {
                                            anchors.centerIn: parent
                                            width: 14
                                            height: 14
                                            source: "qrc:/resources/icons/refresh.svg"
                                            visible: deployingModelIndex !== index
                                        }

                                        Spinner {
                                            anchors.centerIn: parent
                                            width: 14
                                            height: 14
                                            loading: deployingModelIndex === index
                                        }
                                    }
                                }
                            }

                            // Regular deploy button
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 32
                                radius: 6
                                // visible: !sessionSettings.modelExists(modelData)
                                visible: !(modelData && modelData.code_name && deployedModelCodeNames.includes(modelData.code_name))

                                color: buttonHover.hovered ?
                                    (isDarkMode ? "#1F8FFF" : "#1984FF") :
                                    (isDarkMode ? "#0A84FF" : "#007AFF")

                                // Animation cho hover
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                HoverHandler {
                                    id: buttonHover
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var dataDict = {
                                            "name": modelData.name,
                                            "code_name": modelData.code_name,
                                            "gpu_type": gpuTypeCombox.currentText.trim(),
                                            "description": modelData.description,
                                            "preview": modelData.preview
                                        }
                                        modelBuilder.deploy(dataDict)
                                        deployingModelIndex = index
                                    }
                                }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Image {
                                        width: 16
                                        height: 16
                                        source: "qrc:/resources/icons/deploy.svg"
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: deployingModelIndex !== index
                                    }

                                    Spinner {
                                        width: 16
                                        height: 16
                                        loading: deployingModelIndex === index
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "Deploy"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: "#FFFFFF"
                                        font.family: "Inter"
                                        renderType: Text.NativeRendering
                                        anchors.verticalCenter: parent.verticalCenter
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
    }
}