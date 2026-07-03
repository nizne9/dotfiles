import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"
import "../Services"
import "../Widgets"

PopupWindow {
    id: center

    property var shell

    property bool showing: false

    // Note: no grabFocus — niri has a known issue (#1810) where layer-shell
    // popups with grab do not dismiss on outside click, and clicks do not
    // pass through to the parent layer surface either. We rely on explicit
    // close triggers: clock button toggle, ESC handled at shell level, etc.

    implicitWidth: Style.panelWidthL
    implicitHeight: Math.max(Style.panelWidthM, Math.min(560, (container.contentHeight || 0) + Theme.padding * 2))
    color: "transparent"
    visible: showing

    Connections {
        target: shell
        function onNotificationsVisibleChanged() {
            showing = shell.notificationsVisible;
        }
    }

    onShowingChanged: {
        if (showing)
            container.forceActiveFocus();
        else if (shell && shell.notificationsVisible)
            shell.closeNotifications();
    }

    Rectangle {
        id: container
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.background
        border.color: Theme.border
        border.width: 1
        focus: true
        Keys.onEscapePressed: center.showing = false

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

    function takeFocus() {
        container.forceActiveFocus();
    }
}
