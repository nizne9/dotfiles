import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.Modules
import qs.Services
import qs.Common
import qs.Widgets

PanelWindow {
    id: bar
    property var shell

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: Theme.border
            opacity: 0.55
        }

        Row {
            anchors {
                left: parent.left
                leftMargin: Style.gapM
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.barGroupSpacing

            Rectangle {
                id: audioWidget
                width: Style.barAudioWidth
                height: Style.barItemHeight
                radius: Theme.radius
                color: audioHover.hovered ? Theme.surfaceElevated : Theme.surface

                readonly property string iconName: Audio.volumeIcon

                Row {
                    anchors.centerIn: parent
                    spacing: Style.gapXS

                    Icon {
                        name: audioWidget.iconName
                        size: Style.barIconSize
                        color: Audio.isMuted ? Theme.urgent : Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: Audio.isMuted ? "Muted" : Math.round(Audio.volume * 100) + "%"
                        color: Audio.isMuted ? Theme.urgent : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                HoverHandler {
                    id: audioHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: audioPopup.toggle()
                }
            }

            Row {
                spacing: Style.barItemSpacing

                Repeater {
                    model: Niri.workspaces

                    Rectangle {
                        id: wsRect

                        // Guard against null modelData during Repeater regeneration
                        // when Niri.workspaces resets on startup or workspace change.
                        readonly property var ws: modelData || {}
                        readonly property bool selected: ws.is_focused || ws.is_active

                        width: Style.barWorkspaceWidth
                        height: Style.barItemHeight
                        radius: Theme.radius
                        color: selected ? Theme.accent : Theme.surface

                        Text {
                            anchors.centerIn: parent
                            text: ws.name || ws.idx || ws.id || ""
                            color: wsRect.selected ? Theme.background : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (wsRect.ws && wsRect.ws.id !== undefined)
                                    Niri.focusWorkspace(wsRect.ws);
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.42, 720)
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            text: Niri.focusedWindowTitle
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: Style.gapM
                verticalCenter: parent.verticalCenter
            }
            spacing: Style.barGroupSpacing

            Rectangle {
                visible: !!Mpris.currentPlayer
                width: visible ? Style.barIconButtonSize : 0
                height: Style.barItemHeight
                radius: Theme.radius
                color: mprisHover.hovered ? Theme.surfaceElevated : Theme.surface

                Icon {
                    anchors.centerIn: parent
                    name: Mpris.isPlaying ? "pause" : "play"
                    size: Style.barIconSize
                    color: Theme.text
                }

                HoverHandler {
                    id: mprisHover
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (Mpris.currentPlayer)
                            Mpris.currentPlayer.togglePlaying();
                    }
                }
            }

            Rectangle {
                id: trayGroup

                readonly property var primarySystemPatterns: [
                    "network", "nm-applet", "networkmanager", "wireless", "wifi", "wlan", "ethernet", "vpn",
                    "bluetooth", "blueman", "bluez",
                    "fcitx", "rime", "ibus", "input method", "keyboard layout", "kbd"
                ]

                property int overflowItemCount: 0
                property bool overflowNeedsAttention: false

                readonly property bool hasInlineItems: inlineTrayRow.implicitWidth > 0
                readonly property bool hasOverflowItems: overflowItemCount > 0

                visible: hasInlineItems || hasOverflowItems
                width: visible ? inlineTrayRow.implicitWidth + (hasOverflowItems ? Style.trayOverflowWidth : 0) + Style.barTrayInnerPadding * 2 : 0
                height: Style.barItemHeight
                radius: Theme.radius
                color: Theme.surface

                Connections {
                    target: SystemTray.items
                    function onValuesChanged() { trayGroup.schedulePolicyUpdate(); }
                }

                Component.onCompleted: schedulePolicyUpdate()

                Timer {
                    id: policyUpdateTimer
                    interval: 0
                    repeat: false
                    onTriggered: trayGroup.updateOverflowPolicy()
                }

                Row {
                    id: trayRow
                    anchors.centerIn: parent
                    spacing: 0

                    Rectangle {
                        id: overflowButton

                        visible: trayGroup.hasOverflowItems
                        width: visible ? Style.trayOverflowWidth : 0
                        height: Style.barItemHeight
                        radius: Style.radiusS
                        color: overflowHover.hovered || trayOverflow.showing ? Theme.surfaceElevated : "transparent"
                        border.color: trayGroup.overflowNeedsAttention ? Theme.urgent : "transparent"
                        border.width: trayGroup.overflowNeedsAttention ? 1 : 0

                        Text {
                            anchors.centerIn: parent
                            text: "+" + trayGroup.overflowItemCount
                            color: trayGroup.overflowNeedsAttention ? Theme.urgent : Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Font.Medium
                        }

                        HoverHandler {
                            id: overflowHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: trayOverflow.toggle()
                        }
                    }

                    Row {
                        id: inlineTrayRow
                        spacing: 0

                        Repeater {
                            model: SystemTray.items

                            Item {
                                id: inlineTrayItem

                                readonly property var item: modelData
                                readonly property bool inlineItem: trayGroup.isInlineItem(item)
                                readonly property bool needsAttention: item ? item.status === Status.NeedsAttention : false

                                width: inlineItem ? Style.barIconButtonSize : 0
                                height: Style.barItemHeight
                                visible: inlineItem

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width - 2
                                    height: parent.height - 2
                                    radius: Style.radiusS
                                    color: inlineTrayHover.hovered ? Theme.surfaceElevated : "transparent"
                                    border.color: inlineTrayItem.needsAttention ? Theme.urgent : "transparent"
                                    border.width: inlineTrayItem.needsAttention ? 1 : 0
                                }

                                IconImage {
                                    anchors.centerIn: parent
                                    width: Style.barIconSize
                                    height: Style.barIconSize
                                    source: inlineTrayItem.item ? inlineTrayItem.item.icon : ""
                                }

                                HoverHandler {
                                    id: inlineTrayHover
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: event => trayGroup.activateItem(inlineTrayItem, event)
                                }

                                Connections {
                                    target: inlineTrayItem.item
                                    function onIconChanged() { trayGroup.schedulePolicyUpdate(); }
                                    function onStatusChanged() { trayGroup.schedulePolicyUpdate(); }
                                    function onIdChanged() { trayGroup.schedulePolicyUpdate(); }
                                    function onTitleChanged() { trayGroup.schedulePolicyUpdate(); }
                                    function onTooltipTitleChanged() { trayGroup.schedulePolicyUpdate(); }
                                }
                            }
                        }
                    }
                }

                function schedulePolicyUpdate() {
                    policyUpdateTimer.restart();
                }

                function itemKey(item) {
                    if (!item)
                        return "";
                    return ((item.id || "") + " " + (item.title || "") + " " + (item.tooltipTitle || "") + " " + (item.icon || "")).toLowerCase();
                }

                function keyHasAny(key, words) {
                    for (let i = 0; i < words.length; i++) {
                        if (key.indexOf(words[i]) !== -1)
                            return true;
                    }
                    return false;
                }

                function isInlineItem(item) {
                    if (!item || item.status === Status.Passive)
                        return false;
                    return keyHasAny(itemKey(item), primarySystemPatterns);
                }

                function isOverflowItem(item) {
                    if (!item || item.status === Status.Passive)
                        return false;
                    return !isInlineItem(item);
                }

                function updateOverflowPolicy() {
                    const values = SystemTray.items.values || [];
                    let count = 0;
                    let needsAttention = false;
                    for (let i = 0; i < values.length; i++) {
                        const item = values[i];
                        if (isOverflowItem(item)) {
                            count++;
                            if (item.status === Status.NeedsAttention)
                                needsAttention = true;
                        }
                    }
                    overflowItemCount = count;
                    overflowNeedsAttention = needsAttention;
                }

                function activateItem(trayItem, event) {
                    if (!trayItem.item)
                        return;

                    const point = trayItem.mapToItem(null, trayItem.width / 2, trayItem.height);
                    if ((event.button === Qt.RightButton || trayItem.item.onlyMenu) && trayItem.item.hasMenu) {
                        trayItem.item.display(bar, point.x, point.y);
                    } else if (event.button === Qt.MiddleButton) {
                        trayItem.item.secondaryActivate();
                    } else {
                        trayItem.item.activate();
                    }
                }
            }

            Rectangle {
                id: clockWidget
                width: Style.barClockWidth
                height: Style.barItemHeight
                radius: Theme.radius
                color: clockHover.hovered ? Theme.surfaceElevated : Theme.surface

                readonly property bool hasNotifications: Notifications.unreadCount > 0

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "hh:mm")
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Rectangle {
                    visible: parent.hasNotifications
                    width: Style.statusDotSize
                    height: Style.statusDotSize
                    radius: width / 2
                    color: Notifications.doNotDisturb ? Theme.muted : Theme.accent
                    anchors {
                        right: parent.right
                        rightMargin: Style.paddingS
                        top: parent.top
                        topMargin: Style.paddingS
                    }
                }

                HoverHandler {
                    id: clockHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.toggleNotifications(bar.screen)
                }
            }
        }
    }

    TrayOverflowPopup {
        id: trayOverflow
        itemModel: SystemTray.items
        itemCount: trayGroup.overflowItemCount
        itemFilter: item => trayGroup.isOverflowItem(item)
        anchor.window: bar
        anchor.item: overflowButton
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: Style.popupBarOffset
        onItemCountChanged: if (itemCount === 0) close()
    }

    AudioPopup {
        id: audioPopup
        anchor.window: bar
        anchor.item: audioWidget
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: Style.popupBarOffset
    }

    NotificationCenter {
        id: notifCenter
        anchor.window: bar
        anchor.item: clockWidget
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Top | Edges.Right
        anchor.margins.top: Style.popupBarOffset
        shell: bar.shell
        ownerScreen: bar.screen
    }
}
