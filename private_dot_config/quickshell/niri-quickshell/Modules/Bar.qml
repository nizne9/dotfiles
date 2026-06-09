import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../Common"

PanelWindow {
    id: bar

    property var shell
    property var niri
    property var notifications
    property var audioService
    property var mprisService

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: Theme.background
    exclusiveZone: Theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.border
        border.width: 0

        Row {
            id: left
            anchors {
                left: parent.left
                leftMargin: Theme.gap
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Rectangle {
                width: 60
                height: 24
                radius: Theme.radius
                color: Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "Apps"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shell.toggleLauncher()
                }
            }

            Repeater {
                model: niri.workspaces

                Rectangle {
                    width: 26
                    height: 24
                    radius: Theme.radius
                    color: (modelData.is_focused || modelData.is_active) ? Theme.accent : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: modelData.name || modelData.idx || modelData.id
                        color: (modelData.is_focused || modelData.is_active) ? Theme.background : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: niri.focusWorkspace(modelData)
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.42, 720)
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            text: niri.focusedWindowTitle
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
                visible: !!mprisService && !!mprisService.currentPlayer
                width: visible ? 24 : 0
                height: 24
                radius: Theme.radius
                color: Theme.surface

                IconImage {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: mprisService && mprisService.currentPlayer ? (mprisService.currentPlayer.trackArtUrl || Quickshell.iconPath("media-playback-start", "")) : ""
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mprisService && mprisService.currentPlayer ? mprisService.currentPlayer.togglePlaying() : undefined
                }
            }

            Rectangle {
                id: audioWidget
                visible: !!audioService
                width: visible ? 36 : 0
                height: 24
                radius: Theme.radius
                color: Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: audioService ? (audioService.isMuted ? "M" : Math.round(audioService.volume * 100) + "%") : ""
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
                model: SystemTray.items

                Rectangle {
                    id: trayItem

                    readonly property bool active: modelData.status !== Status.Passive

                    width: active ? 24 : 0
                    height: 24
                    radius: Theme.radius
                    visible: active
                    color: trayHover.hovered ? Theme.surfaceElevated : Theme.surface
                    border.color: modelData.status === Status.NeedsAttention ? Theme.urgent : "transparent"
                    border.width: modelData.status === Status.NeedsAttention ? 1 : 0

                    IconImage {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: modelData.icon || ""
                    }

                    HoverHandler {
                        id: trayHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: event => {
                            const point = trayItem.mapToItem(null, trayItem.width / 2, trayItem.height);
                            if ((event.button === Qt.RightButton || modelData.onlyMenu) && modelData.hasMenu) {
                                modelData.display(bar, point.x, point.y);
                            } else if (event.button === Qt.MiddleButton) {
                                modelData.secondaryActivate();
                            } else {
                                modelData.activate();
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: notifWidget
                width: 54
                height: 24
                radius: Theme.radius
                color: notifications.history.length > 0 ? Theme.surfaceElevated : Theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "N " + notifications.history.length
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
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
        audioService: bar.audioService
    }

    NotificationCenter {
        id: notifCenter
        anchor.window: bar
        anchor.rect.x: notifWidget.mapToItem(null, 0, 0).x + notifWidget.width - 360
        anchor.rect.y: Theme.barHeight
        shell: bar.shell
        notifications: bar.notifications
    }
}
