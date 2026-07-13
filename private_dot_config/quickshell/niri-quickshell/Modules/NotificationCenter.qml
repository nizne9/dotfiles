import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

PopupWindow {
    id: center

    property var shell
    property var ownerScreen
    property bool showing: false
    readonly property bool empty: Notifications.history.length === 0
    readonly property int listHeight: empty ? 92 : Math.min(500, history.implicitHeight)

    grabFocus: true
    implicitWidth: Style.panelWidthL
    implicitHeight: Style.paddingM * 2 + header.height + Style.gapM + listHeight
    color: "transparent"
    visible: showing

    onClosed: close()
    onShowingChanged: {
        if (showing) {
            Notifications.setCenterOpen(true);
            Qt.callLater(() => container.forceActiveFocus());
        } else if (!shell || !shell.notificationsVisible) {
            Notifications.setCenterOpen(false);
        }
    }

    Connections {
        target: shell
        function onNotificationsVisibleChanged() { center.syncShowing(); }
        function onNotificationScreenChanged() { center.syncShowing(); }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        radius: Style.radiusL
        color: Theme.background
        border.color: Theme.border
        border.width: 1
        focus: true
        Keys.onEscapePressed: center.close()

        Column {
            anchors.fill: parent
            anchors.margins: Style.paddingM
            spacing: Style.gapM

            Row {
                id: header
                width: parent.width
                height: 30
                spacing: Style.gapXS

                Text {
                    width: parent.width - dndButton.width - clearButton.width - closeButton.width - parent.spacing * 3
                    text: center.empty ? "Notifications" : "Notifications  " + Notifications.history.length
                    color: Theme.text
                    elide: Text.ElideRight
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }

                NotificationIconButton {
                    id: dndButton
                    iconName: Notifications.doNotDisturb ? "notifications-off" : "notifications"
                    accessibleName: Notifications.doNotDisturb ? "Turn off Do Not Disturb" : "Turn on Do Not Disturb"
                    checked: Notifications.doNotDisturb
                    onClicked: Notifications.toggleDoNotDisturb()
                }

                NotificationIconButton {
                    id: clearButton
                    iconName: String.fromCharCode(0xf1f8)
                    accessibleName: "Clear all notifications"
                    danger: true
                    enabled: !center.empty
                    opacity: enabled ? 1 : 0.35
                    onClicked: Notifications.clearHistory()
                }

                NotificationIconButton {
                    id: closeButton
                    iconName: String.fromCharCode(0xf00d)
                    accessibleName: "Close notification center"
                    onClicked: center.close()
                }
            }

            Item {
                width: parent.width
                height: center.listHeight

                Column {
                    anchors.centerIn: parent
                    spacing: Style.gapS
                    visible: center.empty

                    Icon {
                        name: Notifications.doNotDisturb ? "notifications-off" : "notifications"
                        size: Style.iconSizeLarge
                        color: Theme.muted
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: Notifications.doNotDisturb ? "Do Not Disturb is on" : "No notifications"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Flickable {
                    id: list
                    anchors.fill: parent
                    visible: !center.empty
                    contentHeight: history.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick

                    Controls.ScrollBar.vertical: Controls.ScrollBar {
                        policy: Controls.ScrollBar.AsNeeded
                    }

                    Column {
                        id: history
                        width: list.width - (list.contentHeight > list.height ? Style.gapM : 0)
                        spacing: Style.gapM

                        Repeater {
                            model: ScriptModel { values: Notifications.history }

                            NotificationCard {
                                notification: modelData
                                cardColor: Theme.surface
                                actionColor: Theme.surfaceElevated
                                bodyMaxLines: 4
                                dismissOnRightClick: true
                            }
                        }
                    }
                }
            }
        }
    }

    function syncShowing() {
        showing = !!shell && shell.notificationsVisible && shell.notificationScreen === ownerScreen;
    }

    function close() {
        if (shell)
            shell.closeNotifications();
        else
            showing = false;
    }
}
