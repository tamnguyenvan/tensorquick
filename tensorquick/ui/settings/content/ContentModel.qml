import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    required property bool isDarkMode
    required property color textColor

    color: isDarkMode ? "#28282A" : "#F5F5F7"
    property bool isDeploying: false
    property bool isDeployed: false

    // Define readonly color properties
    readonly property color backgroundColor: isDarkMode ? "#28282A" : "#F5F5F7"
    readonly property color currentModelColor: isDarkMode ? "#1D1D1F" : "#FFFFFF"
    readonly property color deployedModelColor: isDarkMode ? "#1D1D1F" : "#FFFFFF"
    readonly property color borderColor: isDarkMode ? "#3D3D3F" : "#E5E5E7"
    readonly property color shadowColor: isDarkMode ? "#40000000" : "#20000000"

    // Main content layout with macOS-style spacing
    ColumnLayout {
        anchors.fill: parent
        anchors {
            leftMargin: 20
            rightMargin: 20
            topMargin: 20
            bottomMargin: 20
        }
        spacing: 20

        // Top section with Current Model and Deployed Models
        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 20

            // Current Model
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: root.currentModelColor
                radius: 12
                border.width: 1
                border.color: root.borderColor

                // Add subtle shadow
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: root.shadowColor
                    radius: 8
                    samples: 16
                    horizontalOffset: 0
                    verticalOffset: 2
                }

                CurrentModel {
                    id: currentModel
                    anchors.fill: parent
                    isDarkMode: root.isDarkMode
                    textColor: root.textColor
                }
            }

            // Deployed Models
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: root.deployedModelColor
                radius: 12
                border.width: 1
                border.color: root.borderColor

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    color: root.shadowColor
                    radius: 8
                    samples: 16
                    horizontalOffset: 0
                    verticalOffset: 2
                }

                DeployedModels {
                    anchors.fill: parent
                    isDarkMode: root.isDarkMode
                    textColor: root.textColor
                    onModelSelected: currentModel
                }
            }
        }

        // Model Gallery section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.6
            color: root.deployedModelColor
            radius: 12
            border.width: 1
            border.color: root.borderColor

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                color: root.shadowColor
                radius: 8
                samples: 16
                horizontalOffset: 0
                verticalOffset: 2
            }

            ModelGallery {
                anchors.fill: parent
                isDarkMode: root.isDarkMode
                textColor: root.textColor
            }
        }
    }
}
