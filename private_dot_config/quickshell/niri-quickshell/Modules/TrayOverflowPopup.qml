import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common

PopupWindow {
    id: popup

    property bool showing: false
    property var itemModel: null
    property var itemFilter: null
    property int itemCount: 0

    grabFocus: true

    onClosed: showing = false

    // Grid layout: up to N columns, wrap to next row.
    readonly property int columns: Math.max(1, Math.min(Style.trayOverflowGridColumns, itemCount))
    readonly property int rows: Math.max(1, Math.ceil(itemCount / columns))
    readonly property int cellSize: Style.trayOverflowCellSize
    readonly property int cellSpacing: Style.gapXS
    readonly property int popupPadding: Style.paddingM

    implicitWidth: columns * cellSize + (columns - 1) * cellSpacing + popupPadding * 2
    implicitHeight: rows * cellSize + (rows - 1) * cellSpacing + popupPadding * 2
    color: "transparent"
    visible: showing && itemCount > 0

    onVisibleChanged: if (!visible) showing = false

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Style.radiusL
        color: Theme.surfaceElevated
        border.color: Theme.border
        border.width: 1

        Grid {
            id: iconGrid
            anchors.centerIn: parent
            columns: popup.columns
            spacing: popup.cellSpacing
            rowSpacing: popup.cellSpacing

            Repeater {
                model: popup.itemModel

                Rectangle {
                    id: cell
                    readonly property var item: modelData
                    readonly property bool included: !!item && !!popup.itemFilter && popup.itemFilter(item)
                    readonly property bool needsAttention: item ? item.status === Status.NeedsAttention : false

                    visible: included
                    width: included ? popup.cellSize : 0
                    height: included ? popup.cellSize : 0
                    radius: Style.radius
                    color: cellHover.hovered ? Theme.surface : "transparent"
                    border.color: needsAttention ? Theme.urgent : "transparent"
                    border.width: needsAttention ? 1 : 0

                    IconImage {
                        width: Style.barIconSize
                        height: Style.barIconSize
                        source: cell.item ? cell.item.icon : ""
                        anchors.centerIn: parent
                    }

                    HoverHandler { id: cellHover }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: event => popup.activateItem(cell, event)
                    }
                }
            }
        }
    }

    function activateItem(cell, event) {
        if (!cell.item)
            return;
        const point = cell.mapToItem(null, cell.width / 2, cell.height / 2);
        if ((event.button === Qt.RightButton || cell.item.onlyMenu) && cell.item.hasMenu) {
            cell.item.display(popup, point.x, point.y);
        } else if (event.button === Qt.MiddleButton) {
            cell.item.secondaryActivate();
        } else {
            cell.item.activate();
            showing = false;
        }
    }

    function toggle() { showing = itemCount > 0 && !showing; }
    function close() { showing = false; }
}
