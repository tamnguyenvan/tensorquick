import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: window
    visible: true
    width: 600
    height: getCurrentHeight()
    minimumWidth: 400

    // Theme properties
    property bool isDarkMode: sessionSettings.currentTheme === "dark"
    readonly property color backgroundColor: isDarkMode ? "#1e1e1e" : "#ffffff"
    readonly property color textColor: isDarkMode ? "#ffffff" : "#000000"
    readonly property color borderColor: isDarkMode ? "#3f3f3f" : "#e5e5e5"
    readonly property color accentColor: isDarkMode ? "#0a84ff" : "#007aff"
    readonly property color secondaryBackgroundColor: isDarkMode ? "#2c2c2c" : "#f5f5f5"
    readonly property color controlBackgroundColor: isDarkMode ? "#323232" : "#e8e8e8"
    readonly property color secondaryTextColor: isDarkMode ? "#a1a1aa" : "#666666"

    // Define heights
    readonly property int compactHeight: 150
    readonly property int expandedHeight: 580
    readonly property int margins: 12
    property bool isInferenceMode: true
    property bool hasDeployedModel: true
    property bool hasResult: false
    property bool isLoading: false

    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"

    // Function to determine current height
    function getCurrentHeight() {
        if (isInferenceMode) {
            return (isLoading || hasResult) ? expandedHeight : (!hasDeployedModel ? compactHeight + 60 : compactHeight)
        }
        return expandedHeight // Training mode always uses expanded height
    }

    // Update height when mode changes
    onIsInferenceModeChanged: {
        height = getCurrentHeight()

        if (!hasDeployedModel && isInferenceMode) {
            warningText.visible = true
        } else {
            warningText.visible = false
        }
    }

    Connections {
        target: inferencePipeline

        function onGenerationCompleted(success) {
            isLoading = false
            if (success) {
                hasResult = true
                window.height = expandedHeight
            } else {
                hasResult = false
                window.height = compactHeight
            }
        }

        function onLoadingChanged(loading) {
            if (loading) {
                hasResult = false
                isLoading = true
                window.height = expandedHeight
            }
        }

        function onCurrentModelChanged(model) {
            if (inferencePipeline && inferencePipeline.currentModel && inferencePipeline.currentModel.code_name) {
                hasDeployedModel = true
            } else {
                hasDeployedModel = false
            }

            if (!hasDeployedModel && isInferenceMode) {
                warningText.visible = true
            } else {
                warningText.visible = false
            }
        }
    }

    Connections {
        target: sessionSettings

        function onThemeChanged(currentTheme) {
            isDarkMode = currentTheme === "dark"
        }
    }

    Component.onCompleted: {
        window.x = (Screen.width - width) / 2
        window.y = Screen.height / 4

        defaultSettings.load()
        sessionSettings.load()

        if (sessionSettings && sessionSettings.currentModel && sessionSettings.currentModel.deployed_url) {
            inferencePipeline.currentModel = sessionSettings.currentModel
        }

        if (sessionSettings && sessionSettings.deployedModels && sessionSettings.deployedModels.length > 0) {
            modelBuilder.deployedModels = sessionSettings.deployedModels
        }

        if (inferencePipeline && inferencePipeline.currentModel && inferencePipeline.currentModel.code_name) {
            hasDeployedModel = true
            warningText.visible = false
        } else {
            hasDeployedModel = false
            if (isInferenceMode) {
                warningText.visible = true
            } else {
                warningText.visible = false
            }
        }

        // Set initial height
        height = getCurrentHeight()
    }

    // Background with macOS style
    Rectangle {
        id: background
        anchors.fill: parent
        color: backgroundColor
        radius: 10
        border.color: borderColor
        border.width: 1
        opacity: 0.98
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (isLoading) {
                    confirmExitDialog.open()
                } else {
                    Qt.quit()
                }
            } else if (event.key === Qt.Key_Return && isInferenceMode) {
                if (inference.inputPrompt.trim() !== "") {
                    inferencePipeline.generateImage(inference.inputPrompt)
                    window.height = expandedHeight
                }
            }
            sessionSettings.save()
        }        // macOS style title bar

        Rectangle {
            id: titleBar
            width: parent.width
            height: 28
            color: "transparent"
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            MouseArea {
                anchors.fill: parent
                property point clickPos: "0,0"
                onPressed: clickPos = Qt.point(mouseX, mouseY)
                onPositionChanged: {
                    var delta = Qt.point(mouseX - clickPos.x, mouseY - clickPos.y)
                    window.x += delta.x
                    window.y += delta.y
                }
            }

            // Window controls (macOS style)
            Row {
                spacing: 8
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                }

                // Close button
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: "#FF5F57"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            sessionSettings.save()
                            if (isLoading || (modelBuilder.loading)) {
                                confirmExitDialog.open()
                            } else {
                                Qt.quit()
                            }
                        }
                        hoverEnabled: true
                    }
                }
            }
        }

        // Mode Switch (macOS style)
        Rectangle {
            id: modeSwitch
            width: 200
            height: 32
            radius: 6
            color: controlBackgroundColor
            anchors {
                top: titleBar.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: margins
            }

            Rectangle {
                id: switchIndicator
                width: parent.width / 2
                height: parent.height - 4
                radius: 4
                color: isDarkMode ? "#404040" : "#ffffff"
                x: isInferenceMode ? 2 : parent.width / 2 - 2
                y: 2

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 2
                    samples: 5
                    color: isDarkMode ? "#40000000" : "#20000000"
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Row {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: "transparent"
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: "Inference"
                        color: isInferenceMode ? textColor : secondaryTextColor
                        font.pixelSize: 13
                        font.family: "Inter"
                        font.weight: Font.Medium

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: isInferenceMode = true
                    }
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: "transparent"
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: "Training"
                        color: !isInferenceMode ? textColor : secondaryTextColor
                        font.pixelSize: 13
                        font.family: "Inter"
                        font.weight: Font.Medium

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: isInferenceMode = false
                    }
                }
            }
        }

        // Theme toggle button
        ToolButton {
            id: themeToggle
            width: 24
            height: 24
            padding: 2
            anchors {
                right: settingsButton.left
                top: parent.top
                margins: margins
            }

            icon.source: isDarkMode ? "qrc:/resources/icons/sun.svg" : "qrc:/resources/icons/moon.svg"
            icon.width: 20
            icon.height: 20
            icon.color: textColor

            background: Rectangle {
                color: themeToggle.hovered ? controlBackgroundColor : "transparent"
                radius: width / 2
            }

            onClicked: {
                isDarkMode = !isDarkMode
                sessionSettings.currentTheme = isDarkMode ? "dark" : "light"
            }
        }

        // Settings button (macOS style)
        ToolButton {
            id: settingsButton
            width: 24
            height: 24
            padding: 2
            anchors {
                right: parent.right
                top: parent.top
                margins: margins
            }

            icon.source: "qrc:/resources/icons/settings.svg"
            icon.width: 20
            icon.height: 20
            icon.color: textColor

            background: Rectangle {
                color: settingsButton.hovered ? controlBackgroundColor : "transparent"
                radius: width / 2
            }

            onClicked: settingsModal.showNormal()
        }

        // Main content stack
        Item {
            id: contentStack
            anchors {
                top: modeSwitch.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 12
                leftMargin: margins * 2
                rightMargin: margins * 2
            }

            // Training Mode Content
            Training {
                isDarkMode: window.isDarkMode
                textColor: window.textColor
                opacity: !isInferenceMode ? 1 : 0
                visible: opacity > 0
            }

            // Inference Mode Content
            Inference {
                id: inference
                isDarkMode: window.isDarkMode
                textColor: window.textColor
                anchors.fill: parent
            }

            // No deployed model warning
            TextWarning {
                id: warningText
            }
        }
    }

    SettingsModal {
        id: settingsModal
        visible: false
        isDarkMode: window.isDarkMode
        textColor: window.textColor
    }

    ConfirmDialog {
        id: confirmExitDialog
        title: "Confirm Exit"
        text: "An operation is in progress. Are you sure you want to exit?"
        onAccepted: Qt.quit()
    }
}