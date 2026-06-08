import QtQuick
import Quickshell
import "../Common"

PanelWindow {
    id: layer

    property var notifications

    Theme {
        id: theme
    }

    anchors {
        top: true
        right: true
    }

    implicitWidth: 360
    implicitHeight: 220
    exclusiveZone: 0
    color: "transparent"
    visible: notifications.toasts.length > 0

    Column {
        anchors {
            top: parent.top
            right: parent.right
            margins: 12
        }
        width: 336
        spacing: theme.gap

        Repeater {
            model: notifications.toasts

            Rectangle {
                width: parent.width
                height: Math.max(70, content.implicitHeight + 20)
                radius: theme.radius
                color: theme.background
                border.color: theme.border
                border.width: 1

                Column {
                    id: content
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: theme.padding
                    }
                    spacing: 3

                    Text {
                        width: parent.width
                        text: modelData.summary || modelData.appName || "Notification"
                        color: theme.text
                        elide: Text.ElideRight
                        font.family: theme.fontFamily
                        font.pixelSize: theme.fontSize
                    }

                    Text {
                        width: parent.width
                        text: modelData.body || ""
                        visible: text.length > 0
                        color: theme.muted
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        font.family: theme.fontFamily
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: notifications.dismiss(modelData.id)
                }
            }
        }
    }
}
