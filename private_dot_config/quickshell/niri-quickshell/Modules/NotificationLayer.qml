import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"
import "../Services"

PanelWindow {
    id: layer

    anchors {
        top: true
        right: true
    }

    implicitWidth: 360
    implicitHeight: 220
    exclusiveZone: 0
    color: "transparent"
    visible: Notifications.toasts.length > 0

    Column {
        anchors {
            top: parent.top
            right: parent.right
            margins: 12
        }
        width: 336
        spacing: Theme.gap

        Repeater {
            model: Notifications.toasts

            Rectangle {
                id: notificationCard

                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property var notificationItem: modelData

                width: parent.width
                height: Math.max(70, content.implicitHeight + 20)
                radius: Theme.radius
                color: Theme.background
                border.color: critical ? Theme.urgent : Theme.border
                border.width: 1

                Column {
                    id: content
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: Theme.padding
                    }
                    spacing: 3

                    Text {
                        width: parent.width
                        text: modelData.summary || modelData.appName || "Notification"
                        color: Theme.text
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        textFormat: Text.PlainText
                    }

                    Text {
                        width: parent.width
                        text: modelData.body || ""
                        visible: text.length > 0
                        color: Theme.muted
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        textFormat: Text.PlainText
                    }

                    Flow {
                        width: parent.width
                        spacing: 6
                        visible: (notificationCard.notificationItem.actions || []).length > 0

                        Repeater {
                            model: notificationCard.notificationItem.actions || []

                            Rectangle {
                                width: Math.max(56, actionText.implicitWidth + 18)
                                height: 24
                                radius: Theme.radius
                                color: actionHover.hovered ? Theme.surfaceElevated : Theme.surface

                                Text {
                                    id: actionText
                                    anchors.centerIn: parent
                                    text: modelData.text || ""
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    textFormat: Text.PlainText
                                }

                                HoverHandler {
                                    id: actionHover
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Notifications.invokeAction(notificationCard.notificationItem.id, modelData)
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: Notifications.dismissToast(notificationCard.notificationItem.id)
                }
            }
        }
    }
}
