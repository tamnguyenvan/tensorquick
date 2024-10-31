import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Custom component for macOS-style group boxes
ColumnLayout {
    Layout.fillWidth: true
    spacing: 6

    required property string title
    required property string content
    required property bool isDarkMode
    required property color textColor

    Text {
        text: title
        font.pixelSize: 13
        font.weight: Font.Medium
        color: isDarkMode ? "#999999" : "#666666"
        font.family: "Inter"
    }

    Text {
        text: content
        font.pixelSize: 14
        color: textColor
        font.family: "Inter"
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        elide: Text.ElideMiddle
    }
}