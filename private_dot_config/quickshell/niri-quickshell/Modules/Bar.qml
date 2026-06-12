import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import qs.Modules
import qs.Services
import qs.Common
import qs.Widgets

PanelWindow {
    id: bar
    property var shell

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        Row {
            anchors {
                left: parent.left
                leftMargin: Theme.gap
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Rectangle {
                id: audioWidget
                width: 40
                height: 24
                radius: Theme.radius
                color: Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: Audio.isMuted ? "M" : Math.round(Audio.volume * 100) + "%"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: audioPopup.show()
                }
            }

            Repeater {
                model: Niri.workspaces

                Rectangle {
                    id: wsRect

                    // Guard against null modelData during Repeater regeneration
                    // when Niri.workspaces resets on startup or workspace change.
                    readonly property var ws: modelData || {}

                    width: 26
                    height: 24
                    radius: Theme.radius
                    color: (ws.is_focused || ws.is_active) ? Theme.accent : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: ws.name || ws.idx || ws.id || ""
                        color: (ws.is_focused || ws.is_active) ? Theme.background : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (wsRect.ws && wsRect.ws.id !== undefined)
                                Niri.focusWorkspace(wsRect.ws);
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.42, 720)
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            text: Niri.focusedWindowTitle
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: Theme.gap
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Rectangle {
                visible: !!Mpris.currentPlayer
                width: visible ? 24 : 0
                height: 24
                radius: Theme.radius
                color: Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: Mpris.currentPlayer?.playbackState === Mpris.Playing ? "⏸" : "▶"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Mpris.currentPlayer?.playPause()
                }
            }

            Repeater {
                model: SystemTray.items

                Rectangle {
                    id: trayItem

                    // Guard against null modelData during Repeater regeneration
                    // when SystemTray.items resets on startup or tray changes.
                    readonly property var item: modelData || {}

                    readonly property bool active: item.status !== Status.Passive

                    width: active ? 24 : 0
                    height: 24
                    radius: Theme.radius
                    visible: active
                    color: trayHover.hovered ? Theme.surfaceElevated : Theme.surface
                    border.color: item.status === Status.NeedsAttention ? Theme.urgent : "transparent"
                    border.width: item.status === Status.NeedsAttention ? 1 : 0

                    IconImage {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: trayItem.item.icon || ""
                    }

                    HoverHandler {
                        id: trayHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: event => {
                            const point = trayItem.mapToItem(null, trayItem.width / 2, trayItem.height);
                            if ((event.button === Qt.RightButton || trayItem.item.onlyMenu) && trayItem.item.hasMenu) {
                                trayItem.item.display(bar, point.x, point.y);
                            } else if (event.button === Qt.MiddleButton) {
                                trayItem.item.secondaryActivate();
                            } else {
                                trayItem.item.activate();
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: notifWidget

                readonly property bool hasNotifications: Notifications.history.length > 0

                visible: hasNotifications
                width: hasNotifications ? Style.widgetHeight : 0
                height: Style.widgetHeight
                radius: Theme.radius
                color: notifHover.hovered ? Theme.surfaceElevated : Theme.surface

                Icon {
                    anchors.centerIn: parent
                    name: "bell"
                    size: Style.iconSize
                    color: Theme.text
                }

                Rectangle {
                    width: 5
                    height: 5
                    radius: 2.5
                    color: Theme.accent
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.top: parent.top
                    anchors.topMargin: 5
                }

                HoverHandler {
                    id: notifHover
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shell.toggleNotifications()
                }
            }

            Rectangle {
                width: 76
                height: 24
                radius: Theme.radius
                color: Theme.surface

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "hh:mm")
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
        }
    }

    AudioPopup {
        id: audioPopup
        anchor.window: bar
        anchor.rect.x: audioWidget.mapToItem(null, 0, 0).x
        anchor.rect.y: Theme.barHeight
    }

    NotificationCenter {
        id: notifCenter
        anchor.window: bar
        anchor.rect.x: bar.width - Theme.gap - Style.panelWidthL
        anchor.rect.y: Theme.barHeight
        shell: bar.shell
    }
}
