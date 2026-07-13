import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"

Rectangle {
    id: card

    property var notification: null
    property color cardColor: Theme.surface
    property color actionColor: Theme.surfaceElevated
    property int bodyMaxLines: 4
    property int spacing: 3
    property bool dismissOnRightClick: true
    property var dismissAction: function(id) { Notifications.dismiss(id); }

    readonly property bool critical: notification ? notification.urgency === NotificationUrgency.Critical : false
    readonly property var actions: notification ? (notification.actions || []) : []

    width: parent.width
    height: Math.max(64, content.implicitHeight + 28)
    radius: Theme.radius
    color: cardColor
    border.color: critical ? Theme.urgent : Theme.border
    border.width: critical ? 1 : 0

    Column {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Theme.padding
        }
        spacing: card.spacing

        Text {
            width: parent.width
            text: card.notification ? (card.notification.summary || card.notification.appName || "Notification") : ""
            color: Theme.text
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            textFormat: Text.PlainText
        }

        Text {
            width: parent.width
            text: card.notification ? (card.notification.body || "") : ""
            visible: text.length > 0
            color: Theme.muted
            wrapMode: Text.Wrap
            maximumLineCount: card.bodyMaxLines
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: 11
            textFormat: Text.PlainText
        }

        Flow {
            width: parent.width
            spacing: 6
            visible: card.actions.length > 0

            Repeater {
                model: card.actions

                Rectangle {
                    id: actionButton

                    readonly property var action: modelData || null

                    visible: !!action
                    width: Math.max(56, actionText.implicitWidth + 18)
                    height: visible ? 24 : 0
                    radius: Theme.radius
                    color: actionHover.hovered ? card.actionColor : card.cardColor

                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: actionButton.action ? actionButton.action.text || "" : ""
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
                        onClicked: {
                            if (card.notification && actionButton.action)
                                Notifications.invokeAction(card.notification.id, actionButton.action);
                        }
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            if (card.dismissOnRightClick && card.notification)
                card.dismissAction(card.notification.id);
        }
    }
}
