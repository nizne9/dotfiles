import QtQuick
import Quickshell
import "../Common"
import "../Services"

PopupWindow {
    id: audioPopup

    property bool showing: false

    implicitWidth: Style.panelWidthM
    implicitHeight: 160
    color: "transparent"
    visible: showing

    onShowingChanged: {
        if (showing) {
            hideTimer.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        opacity: audioPopup.showing ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Anims.durShort
                easing.type: Easing.Bezier
                easing.bezierCurve: Anims.emphasizedDecel
            }
        }

        radius: Style.radius
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
            anchors.margins: Style.paddingM
            spacing: Style.gapM

            Text {
                text: "Audio"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }

            Row {
                width: parent.width
                spacing: Style.gapM

                Rectangle {
                    width: 24
                    height: 24
                    radius: Style.radius
                    color: Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: Audio.isMuted ? "M" : "V"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Audio.toggleMute()
                    }
                }

                Rectangle {
                    width: parent.width - 24 - Style.gapM
                    height: 24
                    radius: Style.radius
                    color: Theme.surface

                    Rectangle {
                        width: Math.max(3, parent.width * Audio.volume)
                        height: parent.height
                        radius: Style.radius
                        color: Theme.accent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => Audio.setVolume(mouse.x / parent.width)
                    }
                }
            }

            Text {
                text: Audio.isMuted ? "Muted" : Math.round(Audio.volume * 100) + "%"
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
    }
}
