import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.Common
import qs.Services

Rectangle {
    id: card

    property var notification: null
    property color cardColor: Theme.surface
    property color actionColor: Theme.surfaceElevated
    property int bodyMaxLines: 4
    property bool dismissOnRightClick: true
    property var dismissAction: function(id) { Notifications.dismiss(id); }

    readonly property bool critical: notification ? notification.urgency === NotificationUrgency.Critical : false
    readonly property var actions: notification ? (notification.actions || []) : []
    readonly property var defaultAction: {
        for (let i = 0; i < actions.length; i++) {
            if (actions[i] && actions[i].identifier === "default")
                return actions[i];
        }
        return null;
    }
    readonly property var visibleActions: actions.filter(action => action && action.identifier !== "default")
    readonly property string appName: notification ? (notification.appName || "Notification") : ""
    readonly property string timeText: notification && notification.createdAt
        ? Qt.formatTime(new Date(notification.createdAt), "hh:mm") : ""

    width: parent ? parent.width : 0
    implicitHeight: Math.max(76, contentRow.implicitHeight + Style.paddingM * 2)
    height: implicitHeight
    radius: Style.radius
    color: cardColor
    border.color: critical ? Theme.urgent : Theme.border
    border.width: critical ? 1 : 0

    Accessible.role: Accessible.ListItem
    Accessible.name: appName + ": " + (notification ? notification.summary || notification.body || "" : "")

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: card.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: event => {
            if (!card.notification)
                return;
            if (event.button === Qt.RightButton && card.dismissOnRightClick)
                card.dismissAction(card.notification.id);
            else if (event.button === Qt.LeftButton && card.defaultAction)
                Notifications.invokeAction(card.notification.id, card.defaultAction);
        }
    }

    Row {
        id: contentRow
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Style.paddingM
        }
        spacing: Style.gapM

        Rectangle {
            width: 32
            height: 32
            radius: Style.radiusS
            color: Theme.surfaceElevated

            IconImage {
                anchors.fill: parent
                anchors.margins: Style.gapS
                source: card.iconSource()
                visible: card.notification && card.notification.appIcon
            }

            Icon {
                anchors.centerIn: parent
                name: card.critical ? String.fromCharCode(0xf071) : "notifications"
                size: Style.iconSize
                color: card.critical ? Theme.urgent : Theme.accent
                visible: !card.notification || !card.notification.appIcon
            }
        }

        Column {
            id: content
            width: contentRow.width - 32 - contentRow.spacing
            spacing: Style.gapXS

            Row {
                width: parent.width
                height: 24
                spacing: Style.gapS

                Text {
                    width: parent.width - timeLabel.width - closeButton.width - parent.spacing * 2
                    text: card.appName
                    color: Theme.muted
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: timeLabel
                    text: card.timeText
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                }

                NotificationIconButton {
                    id: closeButton
                    width: 24
                    height: 24
                    iconName: String.fromCharCode(0xf00d)
                    accessibleName: "Dismiss notification"
                    onClicked: if (card.notification) card.dismissAction(card.notification.id)
                }
            }

            Text {
                width: parent.width
                text: card.notification ? (card.notification.summary || card.appName) : ""
                color: Theme.text
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.Medium
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

            Image {
                width: parent.width
                height: visible ? Math.min(120, Math.max(64, implicitHeight)) : 0
                visible: source.toString().length > 0
                source: card.notification ? card.notification.image || "" : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }

            Flow {
                width: parent.width
                spacing: Style.gapS
                visible: card.visibleActions.length > 0

                Repeater {
                    model: card.visibleActions

                    FocusScope {
                        id: actionButton
                        readonly property var action: modelData || null

                        visible: !!action
                        width: Math.min(parent.width, Math.max(56, actionText.implicitWidth + 18))
                        height: visible ? 26 : 0
                        activeFocusOnTab: visible

                        Accessible.role: Accessible.Button
                        Accessible.name: action ? action.text || "Notification action" : ""
                        Accessible.onPressAction: actionButton.invoke()

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                                actionButton.invoke();
                                event.accepted = true;
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: Style.radiusS
                            color: actionHover.hovered ? card.actionColor : card.cardColor
                            border.color: actionButton.activeFocus ? Theme.accent : Theme.border
                            border.width: 1
                        }

                        Text {
                            id: actionText
                            anchors.fill: parent
                            anchors.leftMargin: Style.gapM
                            anchors.rightMargin: Style.gapM
                            text: actionButton.action ? actionButton.action.text || "" : ""
                            color: Theme.text
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            textFormat: Text.PlainText
                        }

                        HoverHandler { id: actionHover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: actionButton.invoke()
                        }

                        function invoke() {
                            if (card.notification && action)
                                Notifications.invokeAction(card.notification.id, action);
                        }
                    }
                }
            }
        }
    }

    function iconSource() {
        if (!notification || !notification.appIcon)
            return "";
        const name = String(notification.appIcon);
        if (name.indexOf("/") >= 0 || Quickshell.hasThemeIcon(name))
            return Quickshell.iconPath(name, "dialog-information");
        return Quickshell.iconPath("dialog-information");
    }
}
