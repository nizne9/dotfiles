import QtQuick
import Quickshell
import "../Common"

PopupWindow {
    id: audioPopup

    property var audioService
    property bool showing: false

    implicitWidth: 300
    implicitHeight: 160
    color: "transparent"
    visible: showing

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: if (containsMouse) hideTimer.restart()
            onPressed: hideTimer.restart()
        }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.gap

            Text {
                text: "Audio"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }

            Row {
                width: parent.width
                spacing: Theme.gap

                Rectangle {
                    width: 24
                    height: 24
                    radius: Theme.radius
                    color: Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: audioService && audioService.isMuted ? "M" : "V"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: audioService ? audioService.toggleMute() : undefined
                    }
                }

                Rectangle {
                    width: parent.width - 24 - Theme.gap
                    height: 24
                    radius: Theme.radius
                    color: Theme.surface

                    Rectangle {
                        width: Math.max(3, parent.width * (audioService ? audioService.volume : 0))
                        height: parent.height
                        radius: Theme.radius
                        color: Theme.accent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => {
                            if (audioService)
                                audioService.setVolume(mouse.x / parent.width);
                        }
                    }
                }
            }

            Text {
                text: audioService ? (audioService.isMuted ? "Muted" : Math.round(audioService.volume * 100) + "%") : ""
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 3000
        repeat: false
        onTriggered: audioPopup.showing = false
    }

    function show() {
        showing = true;
        hideTimer.restart();
    }
}
