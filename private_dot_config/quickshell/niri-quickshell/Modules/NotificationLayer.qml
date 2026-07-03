import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"
import "../Services"
import "../Widgets"

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
            model: ScriptModel {
                values: Notifications.toasts
            }

            NotificationCard {
                notification: modelData
                cardColor: Theme.background
                actionColor: Theme.surface
                bodyMaxLines: 3
                dismissOnRightClick: true
                dismissAction: function(id) { Notifications.dismissToast(id); }
            }
        }
    }
}
