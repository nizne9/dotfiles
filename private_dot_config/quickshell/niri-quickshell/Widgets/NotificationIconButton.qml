import QtQuick
import QtQuick.Controls as Controls
import qs.Common

FocusScope {
    id: root

    property string iconName: ""
    property string accessibleName: ""
    property string tooltip: accessibleName
    property bool checked: false
    property bool danger: false
    property bool hovered: hover.hovered
    signal clicked

    width: 28
    height: 28
    activeFocusOnTab: enabled

    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.onPressAction: root.clicked()

    Controls.ToolTip.visible: hovered && tooltip.length > 0
    Controls.ToolTip.text: tooltip
    Controls.ToolTip.delay: 500

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.clicked();
            event.accepted = true;
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Style.radiusS
        color: root.checked ? Theme.accent : (root.hovered ? Theme.surfaceElevated : "transparent")
        border.color: root.activeFocus ? Theme.accent : "transparent"
        border.width: root.activeFocus ? 1 : 0

        Behavior on color { ColorAnimation { duration: Anims.durShort } }

        Icon {
            anchors.centerIn: parent
            name: root.iconName
            size: Style.iconSize
            color: root.checked ? Theme.background : (root.danger ? Theme.urgent : Theme.text)
        }
    }

    HoverHandler { id: hover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
