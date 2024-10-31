import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Text {
    id: warningText
    text: "No deployed model available. Please deploy one"
    color: "red"
    font.pixelSize: 14
    visible: !hasDeployedModel
    anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
        bottomMargin: 10  // Add some margin from the bottom
    }
}