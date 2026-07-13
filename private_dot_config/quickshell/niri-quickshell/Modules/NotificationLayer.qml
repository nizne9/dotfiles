import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

PanelWindow {
    id: layer

    readonly property var targetScreen: {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === Niri.focusedOutput)
                return screens[i];
        }
        return screens.length > 0 ? screens[0] : null;
    }

    screen: targetScreen
    anchors {
        top: true
        right: true
    }

    implicitWidth: Style.panelWidthL
    implicitHeight: Math.min(targetScreen ? targetScreen.height : 720,
        Theme.barHeight + Style.gapL * 2 + toastColumn.implicitHeight)
    exclusiveZone: 0
    color: "transparent"
    visible: Notifications.toasts.length > 0 && !Notifications.centerOpen

    Item {
        anchors.fill: parent

        HoverHandler {
            id: layerHover
            onHoveredChanged: {
                if (hovered)
                    Notifications.pauseToasts();
                else
                    Notifications.resumeToasts();
            }
        }

        Column {
            id: toastColumn
            anchors {
                top: parent.top
                topMargin: Theme.barHeight + Style.gapL
                right: parent.right
                rightMargin: Style.gapL
            }
            width: parent.width - Style.gapL * 2
            spacing: Style.gapM

            Repeater {
                model: ScriptModel { values: Notifications.toasts }

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
}
