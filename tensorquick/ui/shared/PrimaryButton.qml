import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root
    implicitWidth: 200
    implicitHeight: 32
    property string iconSource: ""
    property string text: ""
    property bool enabled: false
    signal clicked()

    Button {
        id: button
        enabled: enabled
        anchors.fill: parent

        contentItem: RowLayout {
            spacing: 6
            Item {
                Layout.fillWidth: true
            }
            Image {
                source: root.iconSource
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                opacity: button.enabled ? (button.pressed ? 0.7 : 1.0) : 0.5
            }
            Text {
                text: root.text
                color: button.enabled ? "#000000" : "#999999"
                font.pixelSize: 13
                font.family: "Inter"
                font.weight: Font.Normal
                opacity: button.enabled ? 1.0 : 0.5
            }
            Item {
                Layout.fillWidth: true
            }
        }

        background: Rectangle {
            radius: 5
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: {
                        if (!button.enabled)
                            return "#F5F5F5"
                        if (button.pressed)
                            return "#D0D0D0"
                        if (button.hovered)
                            return "#E8E8E8"
                        return "#FFFFFF"
                    }
                }
                GradientStop {
                    position: 1.0
                    color: {
                        if (!button.enabled)
                            return "#E8E8E8"
                        if (button.pressed)
                            return "#C0C0C0"
                        if (button.hovered)
                            return "#E0E0E0"
                        return "#F0F0F0"
                    }
                }
            }

            border.width: 1
            border.color: {
                if (!button.enabled)
                    return "#D0D0D0"
                if (button.pressed)
                    return "#A0A0A0"
                if (button.hovered)
                    return "#B8B8B8"
                return "#C0C0C0"
            }

            layer.enabled: button.enabled
            layer.effect: DropShadow {
                transparentBorder: true
                color: "#20000000"
                radius: 2
                samples: 5
                horizontalOffset: 0
                verticalOffset: 1
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 100
                    easing.type: Easing.OutQuad
                }
            }
        }

        onClicked: {
            root.clicked()
        }
    }
}