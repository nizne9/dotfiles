import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Common"
import "../Services"
import "../Widgets"

PanelWindow {
    id: osd

    property bool showing: false
    property bool windowVisible: false

    readonly property real displayValue: Audio.isMuted ? 0 : Math.max(0, Math.min(1, Audio.volume))
    readonly property string volumeIcon: Audio.volumeIcon
    readonly property string displayText: Audio.isMuted ? "Muted" : Math.round(Audio.volume * 100) + "%"
    readonly property color stateColor: Audio.isMuted ? Theme.urgent : Theme.accent

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.barHeight + Style.gapXS
        right: Style.gapL
    }

    implicitWidth: 184
    implicitHeight: 42
    exclusiveZone: 0
    color: "transparent"
    visible: windowVisible

    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: Style.gapS
        opacity: osd.showing ? 1 : 0
        scale: osd.showing ? 1 : 0.96
        radius: Style.radius
        color: Theme.surface
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

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: Style.paddingM
                rightMargin: Style.paddingM
            }
            spacing: 0

            Icon {
                id: osdIcon
                name: osd.volumeIcon
                size: Style.iconSize
                color: osd.stateColor
                width: Style.iconSize
                height: Style.iconSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: Style.gapS
                height: 1
            }

            Rectangle {
                id: progressBar
                width: 84
                height: 4
                radius: height / 2
                color: Theme.surfaceElevated
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Math.max(0, parent.width * osd.displayValue)
                    radius: parent.radius
                    color: osd.stateColor

                    Behavior on width {
                        NumberAnimation {
                            duration: Anims.durShort
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Anims.emphasizedDecel
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: Anims.durShort }
                    }
                }
            }

            Item {
                width: parent.width - osdIcon.width - progressBar.width - valueText.width - Style.gapS
                height: 1
            }

            Text {
                id: valueText
                width: 42
                text: osd.displayText
                color: Audio.isMuted ? Theme.urgent : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: osd.hide()
    }

    Timer {
        id: closeTimer
        interval: Anims.durShort + 50
        repeat: false
        onTriggered: {
            if (!osd.showing)
                osd.windowVisible = false;
        }
    }

    function showVolume() {
        closeTimer.stop();
        windowVisible = true;
        showing = true;
        hideTimer.restart();
    }

    function hide() {
        hideTimer.stop();
        showing = false;
        closeTimer.restart();
    }
}
