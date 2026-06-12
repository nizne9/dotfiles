import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Common"

PanelWindow {
    id: osd

    property string label: ""
    property real value: 0
    property string icon: ""
    property bool showing: false

    anchors {
        top: true
        right: true
    }

    implicitWidth: Style.panelWidthS
    implicitHeight: 64
    exclusiveZone: 0
    color: "transparent"
    visible: showing

    WlrLayershell.layer: WlrLayer.Overlay

    onShowingChanged: {
        if (showing)
            hideTimer.restart();
    }

    Rectangle {
        anchors.fill: parent
        opacity: osd.showing ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Anims.durShort
                easing.type: Easing.Bezier
                easing.bezierCurve: Anims.emphasizedDecel
            }
        }
        anchors.margins: 8
        radius: Style.radius
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        Row {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: Style.paddingM
            }
            spacing: Style.gapM

            Text {
                text: osd.icon
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 16
                visible: text.length > 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: osd.label
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                anchors.verticalCenter: parent.verticalCenter
                visible: text.length > 0
            }

            Rectangle {
                width: parent.width - (osd.icon.length > 0 ? 24 : 0) - (osd.label.length > 0 ? osd.label.length * 7 : 0) - Style.gapM * 2
                height: 6
                radius: 3
                color: Theme.surface
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: Math.max(3, parent.width * osd.value)
                    height: parent.height
                    radius: 3
                    color: Theme.accent
                }
            }

            Text {
                text: Math.round(osd.value * 100) + "%"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Timer {
        id: hideTimer
        interval: 2000
        repeat: false
        onTriggered: osd.showing = false
    }

    function show(lbl, val, ico) {
        label = lbl;
        value = val;
        icon = ico || "";
        showing = true;
    }
}
