import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../Common"

PanelWindow {
    id: launcher

    property var shell
    property string query: ""
    property int selectedIndex: 0
    readonly property var filteredEntries: filterEntries(DesktopEntries.applications, query)

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: shell.launcherVisible
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onVisibleChanged: {
        if (visible) {
            query = "";
            selectedIndex = 0;
            search.text = "";
            Qt.callLater(() => search.forceActiveFocus());
        }
    }
    onQueryChanged: selectedIndex = 0

    function matches(entry) {
        const needle = query.trim().toLowerCase();
        if (needle.length === 0)
            return true;

        return String(entry.name || "").toLowerCase().indexOf(needle) >= 0
            || String(entry.genericName || "").toLowerCase().indexOf(needle) >= 0
            || String(entry.comment || "").toLowerCase().indexOf(needle) >= 0;
    }

    function rank(entry) {
        const needle = query.trim().toLowerCase();
        if (needle.length === 0)
            return 0;

        const name = String(entry.name || "").toLowerCase();
        const genericName = String(entry.genericName || "").toLowerCase();
        const comment = String(entry.comment || "").toLowerCase();
        if (name === needle)
            return 80;
        if (name.startsWith(needle))
            return 60;
        if (genericName.startsWith(needle))
            return 40;
        if (name.indexOf(needle) >= 0)
            return 20;
        if (comment.indexOf(needle) >= 0)
            return 10;
        return 0;
    }

    function filterEntries(entries, queryText) {
        const result = [];
        for (let i = 0; i < entries.length; i++) {
            const entry = entries[i];
            if (!entry.noDisplay && launcher.matches(entry))
                result.push(entry);
        }

        return result.sort((a, b) => launcher.rank(b) - launcher.rank(a)
            || String(a.name || "").localeCompare(String(b.name || "")));
    }

    function moveSelection(delta) {
        const count = filteredEntries.length;
        if (count === 0) {
            selectedIndex = 0;
            return;
        }

        selectedIndex = (selectedIndex + delta + count) % count;
        list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function launchEntry(entry) {
        if (!entry)
            return;

        entry.execute();
        shell.closeLauncher();
    }

    function launchSelected() {
        launchEntry(filteredEntries[selectedIndex]);
    }

    function iconSource(icon) {
        const name = String(icon || "");
        if (name.length > 0 && (name.indexOf("/") >= 0 || Quickshell.hasThemeIcon(name)))
            return Quickshell.iconPath(name, "application-x-executable");
        return Quickshell.iconPath("application-x-executable");
    }

    Rectangle {
        anchors.fill: parent
        color: "#00000066"

        MouseArea {
            anchors.fill: parent
            onClicked: shell.closeLauncher()
        }

        Rectangle {
            width: Math.min(parent.width - 48, 720)
            height: Math.min(parent.height - 96, 560)
            anchors {
                top: parent.top
                topMargin: 84
                horizontalCenter: parent.horizontalCenter
            }
            radius: Theme.radius
            color: Theme.background
            border.color: Theme.border
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.gap

                Rectangle {
                    width: parent.width
                    height: 38
                    radius: Theme.radius
                    color: Theme.surface

                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: Theme.padding
                        anchors.rightMargin: Theme.padding
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.background
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        text: launcher.query
                        onTextChanged: launcher.query = text
                        Keys.onEscapePressed: shell.closeLauncher()
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Up) {
                                launcher.moveSelection(-1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Down) {
                                launcher.moveSelection(1);
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                launcher.launchSelected();
                                event.accepted = true;
                            }
                        }
                    }

                    Text {
                        visible: search.text.length === 0
                        anchors {
                            left: parent.left
                            leftMargin: Theme.padding
                            verticalCenter: parent.verticalCenter
                        }
                        text: "Search applications"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                    }
                }

                ListView {
                    id: list
                    width: parent.width
                    height: parent.height - 46
                    clip: true
                    spacing: 4
                    model: launcher.filteredEntries
                    currentIndex: launcher.selectedIndex

                    delegate: Rectangle {
                        id: entry

                        width: list.width
                        height: 46
                        radius: Theme.radius
                        color: index === launcher.selectedIndex || hover.hovered ? Theme.surfaceElevated : Theme.background

                        Row {
                            anchors {
                                left: parent.left
                                leftMargin: Theme.padding
                                right: parent.right
                                rightMargin: Theme.padding
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: Theme.gap

                            IconImage {
                                width: 28
                                height: 28
                                anchors.verticalCenter: parent.verticalCenter
                                source: launcher.iconSource(modelData.icon)
                            }

                            Column {
                                width: parent.width - 36
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    width: parent.width
                                    text: modelData.name || ""
                                    elide: Text.ElideRight
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    textFormat: Text.PlainText
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.comment || modelData.genericName || ""
                                    elide: Text.ElideRight
                                    visible: text.length > 0
                                    color: Theme.muted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    textFormat: Text.PlainText
                                }
                            }
                        }

                        HoverHandler {
                            id: hover
                            onHoveredChanged: {
                                if (hovered)
                                    launcher.selectedIndex = index;
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: launcher.launchEntry(modelData)
                        }
                    }
                }
            }
        }
    }
}
