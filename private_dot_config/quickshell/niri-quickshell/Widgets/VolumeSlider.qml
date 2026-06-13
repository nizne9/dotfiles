import QtQuick
import "../Common"

Item {
    id: root

    property real value: 0
    property real minimum: 0
    property real maximum: 1
    property real step: 0.01
    property bool dragging: false
    property bool wheelEnabled: true
    property bool showTooltip: true
    property string unit: "%"

    readonly property bool hovered: sliderArea.containsMouse
    readonly property int displayValue: Math.round(value * 100)
    readonly property real range: Math.max(0.0001, maximum - minimum)
    readonly property real position: Math.max(0, Math.min(1, (value - minimum) / range))

    signal moved(real newValue)
    signal dragFinished(real finalValue)
    signal interactionStarted()
    signal interactionEnded()

    implicitHeight: 40

    function valueFromX(x) {
        const ratio = Math.max(0, Math.min(1, x / Math.max(1, track.width)));
        const raw = minimum + ratio * range;
        const stepped = step > 0 ? Math.round(raw / step) * step : raw;
        return Math.max(minimum, Math.min(maximum, stepped));
    }

    function setFromX(x) {
        const newValue = valueFromX(x);
        if (Math.abs(newValue - value) > 0.0001) {
            value = newValue;
            moved(newValue);
        }
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 10
        radius: height / 2
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        clip: true

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(root.value <= root.minimum ? 0 : 4, parent.width * root.position)
            radius: parent.radius
            color: root.enabled ? Theme.accent : Theme.muted

            Behavior on width {
                enabled: !root.dragging
                NumberAnimation {
                    duration: Anims.durShort
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Anims.standard
                }
            }
        }
    }

    Rectangle {
        id: handle
        width: root.dragging || root.hovered ? 6 : 4
        height: root.dragging || root.hovered ? 24 : 20
        radius: width / 2
        x: Math.max(0, Math.min(parent.width - width, track.x + track.width * root.position - width / 2))
        anchors.verticalCenter: track.verticalCenter
        color: root.enabled ? Theme.accent : Theme.muted
        border.color: Theme.background
        border.width: 1

        Behavior on width { NumberAnimation { duration: Anims.durShort } }
        Behavior on height { NumberAnimation { duration: Anims.durShort } }
        Behavior on x {
            enabled: !root.dragging
            NumberAnimation {
                duration: Anims.durShort
                easing.type: Easing.Bezier
                easing.bezierCurve: Anims.standard
            }
        }
    }

    Rectangle {
        id: tooltip
        width: valueText.width + Style.paddingS * 2
        height: 24
        radius: Style.radiusS
        color: Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1
        x: Math.max(0, Math.min(parent.width - width, handle.x + handle.width / 2 - width / 2))
        y: -height - Style.gapS
        opacity: root.showTooltip && (root.dragging || root.hovered) ? 1 : 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: Anims.durShort } }

        Text {
            id: valueText
            anchors.centerIn: parent
            text: root.displayValue + root.unit
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        id: sliderArea
        anchors.fill: parent
        anchors.topMargin: -4
        anchors.bottomMargin: -4
        hoverEnabled: true
        enabled: root.enabled
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        onPressed: mouse => {
            root.dragging = true;
            root.interactionStarted();
            root.setFromX(mouse.x);
        }

        onPositionChanged: mouse => {
            if (pressed && root.dragging)
                root.setFromX(mouse.x);
        }

        onReleased: {
            root.dragging = false;
            root.dragFinished(root.value);
            root.interactionEnded();
        }

        onCanceled: {
            root.dragging = false;
            root.interactionEnded();
        }

        onWheel: wheel => {
            if (!root.wheelEnabled) {
                wheel.accepted = false;
                return;
            }
            const delta = wheel.angleDelta.y || wheel.angleDelta.x;
            const next = Math.max(root.minimum, Math.min(root.maximum, root.value + (delta > 0 ? root.step : -root.step)));
            if (Math.abs(next - root.value) > 0.0001) {
                root.value = next;
                root.moved(next);
            }
            wheel.accepted = true;
        }
    }
}
