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

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: Theme.border
            opacity: 0.55
        }

        Row {
            anchors {
                left: parent.left
                leftMargin: Style.gapM
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.barGroupSpacing

            Rectangle {
                id: audioWidget
                width: Style.barAudioWidth
                height: Style.barItemHeight
                radius: Theme.radius
                color: audioHover.hovered ? Theme.surfaceElevated : Theme.surface

                readonly property string iconName: {
                    if (Audio.isMuted || Audio.volume <= 0)
                        return "volume-muted";
                    if (Audio.volume < 0.34)
                        return "volume-low";
                    if (Audio.volume < 0.67)
                        return "volume-medium";
                    return "volume-high";
                }

                Row {
                    anchors.centerIn: parent
                    spacing: Style.gapXS

                    Icon {
                        name: audioWidget.iconName
                        size: Style.barIconSize
                        color: Audio.isMuted ? Theme.urgent : Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: Audio.isMuted ? "Muted" : Math.round(Audio.volume * 100) + "%"
                        color: Audio.isMuted ? Theme.urgent : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                HoverHandler {
                    id: audioHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: audioPopup.toggle()
                }
            }

            Row {
                spacing: Style.barItemSpacing

                Repeater {
                    model: Niri.workspaces

                    Rectangle {
                        id: wsRect

                        // Guard against null modelData during Repeater regeneration
                        // when Niri.workspaces resets on startup or workspace change.
                        readonly property var ws: modelData || {}
                        readonly property bool selected: ws.is_focused || ws.is_active

                        width: Style.barWorkspaceWidth
                        height: Style.barItemHeight
                        radius: Theme.radius
                        color: selected ? Theme.accent : Theme.surface

                        Text {
                            anchors.centerIn: parent
                            text: ws.name || ws.idx || ws.id || ""
                            color: wsRect.selected ? Theme.background : Theme.text
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
                rightMargin: Style.gapM
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.barGroupSpacing

            Rectangle {
                visible: !!Mpris.currentPlayer
                width: visible ? Style.barIconButtonSize : 0
                height: Style.barItemHeight
                radius: Theme.radius
                color: mprisHover.hovered ? Theme.surfaceElevated : Theme.surface

                Icon {
                    anchors.centerIn: parent
                    name: Mpris.currentPlayer?.playbackState === Mpris.Playing ? "pause" : "play"
                    size: Style.barIconSize
                    color: Theme.text
                }

                HoverHandler {
                    id: mprisHover
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Mpris.currentPlayer?.playPause()
                }
            }

            Rectangle {
                id: trayGroup

                visible: trayRow.implicitWidth > 0
                width: visible ? trayRow.implicitWidth + Style.paddingS * 2 : 0
                height: Style.barItemHeight
                radius: Theme.radius
                color: Theme.surface

                Row {
                    id: trayRow
                    anchors.centerIn: parent
                    spacing: 0

                    Repeater {
                        model: SystemTray.items

                        Item {
                            id: trayItem

                            // Guard against null modelData during Repeater regeneration
                            // when SystemTray.items resets on startup or tray changes.
                            readonly property var item: modelData || null
                            readonly property bool active: item && item.status !== Status.Passive
                            readonly property bool needsAttention: item && item.status === Status.NeedsAttention

                            width: active ? Style.barIconButtonSize : 0
                            height: Style.barItemHeight
                            visible: active

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 2
                                height: parent.height - 2
                                radius: Style.radiusS
                                color: trayHover.hovered ? Theme.surfaceElevated : "transparent"
                                border.color: trayItem.needsAttention ? Theme.urgent : "transparent"
                                border.width: trayItem.needsAttention ? 1 : 0
                            }

                            IconImage {
                                anchors.centerIn: parent
                                width: Style.barIconSize
                                height: Style.barIconSize
                                source: trayItem.item.icon || ""
                            }

                            HoverHandler {
                                id: trayHover
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                onClicked: event => {
                                    if (!trayItem.item)
                                        return;
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
                }
            }

            Rectangle {
                width: Style.barClockWidth
                height: Style.barItemHeight
                radius: Theme.radius
                color: clockHover.hovered ? Theme.surfaceElevated : Theme.surface

                readonly property bool hasNotifications: Notifications.history.length > 0

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

                Rectangle {
                    visible: parent.hasNotifications
                    width: Style.statusDotSize
                    height: Style.statusDotSize
                    radius: width / 2
                    color: Theme.accent
                    anchors {
                        right: parent.right
                        rightMargin: Style.paddingS
                        top: parent.top
                        topMargin: Style.paddingS
                    }
                }

                HoverHandler {
                    id: clockHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.toggleNotifications()
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
        anchor.rect.x: bar.width - Style.gapM - Style.panelWidthL
        anchor.rect.y: Theme.barHeight
        shell: bar.shell
    }
}
