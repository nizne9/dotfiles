import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common

PopupWindow {
    id: popup

    property bool showing: false
    property var items: []

    implicitWidth: Style.trayOverflowIconOnlyWidth
    implicitHeight: Math.min(
        Style.trayOverflowRowHeight * Style.trayOverflowMaxVisibleRows + Style.paddingM * 2 + Style.gapS * 2,
        overflowList.contentHeight + Style.paddingM * 2 + Style.gapS * 2
    )
    color: "transparent"
    visible: showing && items.length > 0

    onVisibleChanged: if (!visible) showing = false

    Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: Style.gapS
        radius: Style.radiusL
        color: Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1

        Flickable {
            id: overflowList
            anchors.fill: parent
            anchors.margins: Style.paddingM
            contentHeight: listColumn.implicitHeight
            clip: true

            Column {
                id: listColumn
                width: overflowList.width
                spacing: Style.gapXS

                Repeater {
                    model: popup.items

                    Rectangle {
                        id: row
                        readonly property var item: modelData || null
                        readonly property bool needsAttention: item ? item.status === Status.NeedsAttention : false

                        width: listColumn.width
                        height: Style.trayOverflowRowHeight
                        radius: Style.radius
                        color: rowHover.hovered ? Theme.surface : "transparent"
                        border.color: needsAttention ? Theme.urgent : "transparent"
                        border.width: needsAttention ? 1 : 0

                        IconImage {
                            width: Style.barIconSize
                            height: Style.barIconSize
                            source: row.item ? row.item.icon : ""
                            anchors.centerIn: parent
                        }

                        HoverHandler { id: rowHover }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: event => popup.activateItem(row, event)
                        }
                    }
                }
            }
        }
    }

    function activateItem(row, event) {
        if (!row.item)
            return;
        const point = row.mapToItem(null, row.width / 2, row.height / 2);
        if ((event.button === Qt.RightButton || row.item.onlyMenu) && row.item.hasMenu) {
            row.item.display(popup, point.x, point.y);
        } else if (event.button === Qt.MiddleButton) {
            row.item.secondaryActivate();
        } else {
            row.item.activate();
            showing = false;
        }
    }

    function toggle() { showing = items.length > 0 && !showing; }
    function close() { showing = false; }
}
