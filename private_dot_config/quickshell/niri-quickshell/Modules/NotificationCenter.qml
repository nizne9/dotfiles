import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"

PopupWindow {
    id: center

    property var shell
    property var notifications

    implicitWidth: 360
    implicitHeight: Math.min(560, container.contentHeight + Theme.padding * 2)
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
        onActiveFocusChanged: if (!activeFocus) shell.closeNotifications()
        Keys.onEscapePressed: shell.closeNotifications()

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
                        onClicked: notifications.clearHistory()
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
                        model: notifications.history

                        Rectangle {
                            id: notificationCard

                            // During a model rebuild the Repeater may briefly
                            // hand us a null modelData. Hoist a guarded view
                            // onto it so every binding below stays total.
                            readonly property var item: modelData || {}
                            readonly property bool critical: item.urgency === NotificationUrgency.Critical
                            readonly property var actions: item.actions || []

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
                                    text: notificationCard.item.summary || notificationCard.item.appName || "Notification"
                                    color: Theme.text
                                    elide: Text.ElideRight
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    textFormat: Text.PlainText
                                }

                                Text {
                                    width: parent.width
                                    text: notificationCard.item.body || ""
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
                                    visible: notificationCard.actions.length > 0

                                    Repeater {
                                        model: notificationCard.actions

                                        Rectangle {
                                            id: actionButton

                                            // Per-action guard for the same reason:
                                            // modelData can be null between rebuilds.
                                            readonly property var action: modelData || {}

                                            width: Math.max(56, actionText.implicitWidth + 18)
                                            height: 24
                                            radius: Theme.radius
                                            color: actionHover.hovered ? Theme.surfaceElevated : Theme.background

                                            Text {
                                                id: actionText
                                                anchors.centerIn: parent
                                                text: actionButton.action.text || ""
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
                                                onClicked: notifications.invokeAction(notificationCard.item.id, actionButton.action)
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                onClicked: notifications.dismiss(notificationCard.item.id)
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
