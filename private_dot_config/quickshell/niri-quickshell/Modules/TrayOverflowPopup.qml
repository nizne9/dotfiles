import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common

PopupWindow {
    id: popup

    property bool showing: false
    property var items: []

    // Measure text labels to size popup to content instead of a fixed width.
    TextMetrics {
        id: labelMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    // Content width from items: widest label + icon + spacing + row padding.
    readonly property int contentWidth: {
        let maxLabel = 0;
        let anyLabel = false;
        for (let i = 0; i < items.length; i++) {
            const lbl = itemLabel(items[i]);
            if (lbl.length > 0) {
                anyLabel = true;
                labelMetrics.text = lbl;
                if (labelMetrics.width > maxLabel)
                    maxLabel = labelMetrics.width;
            }
        }
        if (!anyLabel)
            return Style.trayOverflowIconOnlyWidth;
        // icon + spacing + label + left/right padding + a bit of breathing room
        const natural = Style.paddingS * 2 + Style.barIconSize + Style.gapS + maxLabel + Style.paddingS;
        return Math.max(Style.trayOverflowIconOnlyWidth, Math.min(natural, Style.trayOverflowPopupWidth));
    }

    implicitWidth: contentWidth
    implicitHeight: Math.min(Style.trayOverflowRowHeight * Style.trayOverflowMaxVisibleRows + Style.paddingM * 2 + Style.gapS * 2, overflowList.contentHeight + Style.paddingM * 2 + Style.gapS * 2)
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
                        readonly property string label: popup.itemLabel(item)
                        readonly property bool hasLabel: label.length > 0
                        readonly property bool needsAttention: item ? item.status === Status.NeedsAttention : false

                        width: listColumn.width
                        height: Style.trayOverflowRowHeight
                        radius: Style.radius
                        color: rowHover.hovered ? Theme.surface : "transparent"
                        border.color: needsAttention ? Theme.urgent : "transparent"
                        border.width: needsAttention ? 1 : 0

                        Row {
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: Style.paddingS
                                rightMargin: Style.paddingS
                            }
                            spacing: Style.gapS

                            IconImage {
                                width: Style.barIconSize
                                height: Style.barIconSize
                                source: row.item ? row.item.icon : ""
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                visible: row.hasLabel
                                width: parent.width - Style.barIconSize - parent.spacing
                                text: row.label
                                color: row.needsAttention ? Theme.urgent : Theme.text
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        HoverHandler {
                            id: rowHover
                        }

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

    // Returns a user-facing label for a tray item, or an empty string when
    // all available metadata is garbage (e.g. Electron's "chrome_status_icon_1")
    // so the icon alone identifies the app.
    function itemLabel(item) {
        if (!item)
            return "";

        // Step 1: check user-configured overrides first.
        const overridden = TrayLabelOverrides.lookup(item);
        if (overridden.length > 0)
            return overridden;

        // Step 2: try SNI metadata with garbage-name filtering.
        const tooltip = ((item.tooltipTitle || "") + "").trim();
        if (tooltip.length > 0 && !isGarbageTrayName(tooltip))
            return tooltip;

        const title = ((item.title || "") + "").trim();
        if (title.length > 0 && !isGarbageTrayName(title))
            return title;

        const id = ((item.id || "") + "").trim();
        if (id.length > 0 && !isGarbageTrayName(id))
            return id;

        return "";
    }

    // Electron's StatusNotifierItem implementation reports a generic
    // "chrome_status_icon_N" id/title for every Electron app (see
    // electron/electron#40936). Other tray libraries follow similar patterns.
    // Treat these as missing names so the icon alone identifies the app.
    function isGarbageTrayName(name) {
        if (!name)
            return true;
        return /^(chrome_status_icon|status_icon|appindicator|app[-_]indicator|tray[-_]icon)([-_]\d+)?$/i.test(name);
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

    function toggle() {
        showing = items.length > 0 && !showing;
    }

    function close() {
        showing = false;
    }
}
