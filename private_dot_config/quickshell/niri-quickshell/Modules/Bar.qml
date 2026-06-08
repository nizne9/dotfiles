import QtQuick
import Quickshell
import "../Common"

PanelWindow {
    id: bar

    property var shell
    property var niri
    property var notifications

    Theme {
        id: theme
    }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: theme.barHeight
    color: theme.background
    exclusiveZone: theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: theme.background
        border.color: theme.border
        border.width: 0

        Row {
            id: left
            anchors {
                left: parent.left
                leftMargin: theme.gap
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Rectangle {
                width: 60
                height: 24
                radius: theme.radius
                color: theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "Apps"
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: theme.fontSize
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
                    radius: theme.radius
                    color: (modelData.is_focused || modelData.is_active) ? theme.accent : theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: modelData.name || modelData.idx || modelData.id
                        color: (modelData.is_focused || modelData.is_active) ? theme.background : theme.text
                        font.family: theme.fontFamily
                        font.pixelSize: theme.fontSize
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
            color: theme.muted
            font.family: theme.fontFamily
            font.pixelSize: theme.fontSize
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: theme.gap
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Rectangle {
                width: 54
                height: 24
                radius: theme.radius
                color: notifications.history.length > 0 ? theme.surfaceElevated : theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "N " + notifications.history.length
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: shell.toggleNotifications()
                }
            }

            Rectangle {
                width: 76
                height: 24
                radius: theme.radius
                color: theme.surface

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "hh:mm")
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: theme.fontSize
                }
            }
        }
    }
}
