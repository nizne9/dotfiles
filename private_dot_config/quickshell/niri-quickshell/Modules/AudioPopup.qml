import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets

PopupWindow {
    id: audioPopup

    property bool showing: false
    property bool pointerInside: false
    property bool interacting: false
    property real localVolume: Audio.volume
    property bool suppressingOsd: false

    readonly property bool interactive: pointerInside || interacting
    readonly property string volumeIcon: {
        if (Audio.isMuted || localVolume <= 0)
            return "volume-muted";
        if (localVolume < 0.34)
            return "volume-low";
        if (localVolume < 0.67)
            return "volume-medium";
        return "volume-high";
    }

    implicitWidth: Style.panelWidthM
    implicitHeight: 132
    color: "transparent"
    visible: showing

    onShowingChanged: {
        setOsdSuppressed(showing);
        if (showing) {
            localVolume = Audio.volume;
            restartHideTimer();
        } else {
            hideTimer.stop();
            pointerInside = false;
            interacting = false;
        }
    }

    Component.onDestruction: setOsdSuppressed(false)

    onInteractiveChanged: restartHideTimer()

    Connections {
        target: Audio
        function onVolumeChanged() {
            if (!audioPopup.interacting)
                audioPopup.localVolume = Audio.volume;
        }
        function onIsMutedChanged() {
            if (!audioPopup.interacting)
                audioPopup.localVolume = Audio.volume;
        }
    }

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: Style.gapS
        opacity: audioPopup.showing ? 1 : 0
        scale: audioPopup.showing ? 1 : 0.96
        radius: Style.radiusL
        color: Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1

        Behavior on opacity {
            NumberAnimation {
                duration: Anims.durShort
                easing.type: Easing.Bezier
                easing.bezierCurve: Anims.emphasizedDecel
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Anims.durShort
                easing.type: Easing.Bezier
                easing.bezierCurve: Anims.emphasizedDecel
            }
        }

        MouseArea {
            id: panelMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onContainsMouseChanged: audioPopup.pointerInside = containsMouse
        }

        Column {
            anchors.fill: parent
            anchors.margins: Style.paddingL
            spacing: Style.gapL

            Row {
                width: parent.width
                height: 24
                spacing: Style.gapS

                Icon {
                    name: "audio"
                    size: Style.iconSize
                    color: Theme.accent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    width: parent.width - valueText.width - Style.iconSize - Style.gapS * 2
                    text: "Audio"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 2
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: valueText
                    text: Audio.isMuted ? "Muted" : Math.round(audioPopup.localVolume * 100) + "%"
                    color: Audio.isMuted ? Theme.urgent : Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: Style.radius
                color: Theme.surface
                border.color: Theme.border
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.paddingS
                    anchors.rightMargin: Style.paddingM
                    spacing: Style.gapM

                    Rectangle {
                        id: muteButton
                        width: 34
                        height: 34
                        radius: height / 2
                        color: muteMouse.containsMouse ? Theme.surfaceElevated : "transparent"
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color { ColorAnimation { duration: Anims.durShort } }

                        Icon {
                            anchors.centerIn: parent
                            name: audioPopup.volumeIcon
                            size: Style.iconSize
                            color: Audio.isMuted ? Theme.urgent : Theme.accent
                        }

                        MouseArea {
                            id: muteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPressed: audioPopup.interacting = true
                            onReleased: audioPopup.interacting = false
                            onCanceled: audioPopup.interacting = false
                            onClicked: Audio.toggleMute()
                        }
                    }

                    VolumeSlider {
                        id: volumeSlider
                        width: parent.width - muteButton.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        step: 0.01
                        enabled: !!(Audio.sink && Audio.sink.ready && Audio.sink.audio)
                        onInteractionStarted: audioPopup.interacting = true
                        onInteractionEnded: audioPopup.interacting = false
                        onMoved: newValue => {
                            audioPopup.localVolume = newValue;
                            Audio.setVolume(newValue);
                        }

                        Binding on value {
                            value: audioPopup.localVolume
                            when: !volumeSlider.dragging
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 3500
        repeat: false
        onTriggered: {
            if (audioPopup.interactive) {
                restart();
            } else {
                audioPopup.showing = false;
            }
        }
    }

    function restartHideTimer() {
        if (!showing)
            return;
        if (interactive) {
            hideTimer.stop();
        } else {
            hideTimer.restart();
        }
    }

    function setOsdSuppressed(suppressed) {
        if (suppressingOsd === suppressed)
            return;
        suppressingOsd = suppressed;
        Audio.osdSuppressionCount = Math.max(0, Audio.osdSuppressionCount + (suppressed ? 1 : -1));
    }

    function show() {
        localVolume = Audio.volume;
        showing = true;
        restartHideTimer();
    }

    function toggle() {
        if (showing) {
            showing = false;
        } else {
            show();
        }
    }
}
