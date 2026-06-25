import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"
import "../Services"

PopupWindow {
    id: center

    property var shell
    property bool hovering: hoverHandler.hovered

    implicitWidth: 360
    implicitHeight: Math.max(120, Math.min(560, (container.contentHeight || 0) + Theme.padding * 2))
    color: "transparent"

    visible: shell.notificationsVisible
    onVisibleChanged: if (visible) center.takeFocus()

    Rectangle {
        id: container
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.background
        border.color: Theme.border
        border.width: 1
        Keys.onEscapePressed: shell.closeNotifications()

        HoverHandler {
            id: hoverHandler
        }

        property real contentHeight: mainColumn.implicitHeight

        Column {
            id: mainColumn
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.gap

            Row {
                width: parent.width
                height: 28

                Text {
                    width: parent.width - 80
                    text: "Notifications"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                }

                Text {
                    width: 80
                    horizontalAlignment: Text.AlignRight
                    text: "Clear"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Notifications.clearHistory()
                    }
                }
            }

            Flickable {
                width: parent.width
                height: mainColumn.height - 36
                contentHeight: history.height
                clip: true

                Column {
                    id: history
                    width: parent.width
                    spacing: Theme.gap

                    Repeater {
                        model: ScriptModel {
                            values: Notifications.history
                        }

                        Rectangle {
                            id: notificationCard

                            readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                            readonly property var notificationItem: modelData

                            width: history.width
                            height: Math.max(64, body.implicitHeight + 28)
                            radius: Theme.radius
                            color: Theme.surface
                            border.color: critical ? Theme.urgent : "transparent"
                            border.width: critical ? 1 : 0

                            Column {
                                id: body
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
                                    maximumLineCount: 4
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
                                            color: actionHover.hovered ? Theme.surfaceElevated : Theme.background

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
                                onClicked: Notifications.dismiss(notificationCard.notificationItem.id)
                            }
                        }
                    }
                }
            }
        }
    }

    function takeFocus() {
        container.forceActiveFocus();
    }
}
