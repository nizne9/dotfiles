import QtQuick
import Quickshell
import "../Common"

PanelWindow {
    id: center

    property var shell
    property var notifications

    Theme {
        id: theme
    }

    anchors {
        top: true
        bottom: true
        right: true
    }

    implicitWidth: 390
    visible: shell.notificationsVisible
    exclusiveZone: 0
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#00000033"

        MouseArea {
            anchors.fill: parent
            onClicked: shell.closeNotifications()
        }

        Rectangle {
            width: 360
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: 12
            }
            radius: theme.radius
            color: theme.background
            border.color: theme.border
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: theme.padding
                spacing: theme.gap

                Row {
                    width: parent.width
                    height: 28

                    Text {
                        width: parent.width - 80
                        text: "Notifications"
                        color: theme.text
                        font.family: theme.fontFamily
                        font.pixelSize: 15
                    }

                    Text {
                        width: 80
                        horizontalAlignment: Text.AlignRight
                        text: "Clear"
                        color: theme.accent
                        font.family: theme.fontFamily
                        font.pixelSize: theme.fontSize

                        MouseArea {
                            anchors.fill: parent
                            onClicked: notifications.clearHistory()
                        }
                    }
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 36
                    contentHeight: history.height
                    clip: true

                    Column {
                        id: history
                        width: parent.width
                        spacing: theme.gap

                        Repeater {
                            model: notifications.history

                            Rectangle {
                                width: history.width
                                height: Math.max(64, body.implicitHeight + 28)
                                radius: theme.radius
                                color: theme.surface

                                Column {
                                    id: body
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
                                        maximumLineCount: 4
                                        elide: Text.ElideRight
                                        font.family: theme.fontFamily
                                        font.pixelSize: 11
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
