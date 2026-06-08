import QtQuick
import Quickshell
import "../Common"

PanelWindow {
    id: launcher

    property var shell
    property string query: ""

    Theme {
        id: theme
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: shell.launcherVisible
    exclusiveZone: 0
    color: "transparent"
    onVisibleChanged: {
        if (visible) {
            query = "";
            search.text = "";
            search.forceActiveFocus();
        }
    }

    function matches(entry) {
        const needle = query.trim().toLowerCase();
        if (needle.length === 0)
            return true;

        return String(entry.name || "").toLowerCase().indexOf(needle) >= 0
            || String(entry.genericName || "").toLowerCase().indexOf(needle) >= 0
            || String(entry.comment || "").toLowerCase().indexOf(needle) >= 0;
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
            radius: theme.radius
            color: theme.background
            border.color: theme.border
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: theme.padding
                spacing: theme.gap

                Rectangle {
                    width: parent.width
                    height: 38
                    radius: theme.radius
                    color: theme.surface

                    TextInput {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: theme.padding
                        anchors.rightMargin: theme.padding
                        verticalAlignment: TextInput.AlignVCenter
                        color: theme.text
                        selectionColor: theme.accent
                        selectedTextColor: theme.background
                        font.family: theme.fontFamily
                        font.pixelSize: 14
                        text: launcher.query
                        onTextChanged: launcher.query = text
                        Keys.onEscapePressed: shell.closeLauncher()
                    }

                    Text {
                        visible: search.text.length === 0
                        anchors {
                            left: parent.left
                            leftMargin: theme.padding
                            verticalCenter: parent.verticalCenter
                        }
                        text: "Search applications"
                        color: theme.muted
                        font.family: theme.fontFamily
                        font.pixelSize: 14
                    }
                }

                Flickable {
                    id: list
                    width: parent.width
                    height: parent.height - 46
                    contentHeight: entries.height
                    clip: true

                    Column {
                        id: entries
                        width: list.width
                        spacing: 4

                        Repeater {
                            model: DesktopEntries.applications

                            Rectangle {
                                width: entries.width
                                height: visible ? 42 : 0
                                visible: launcher.matches(modelData)
                                radius: theme.radius
                                color: hover.hovered ? theme.surfaceElevated : theme.background

                                Column {
                                    anchors {
                                        left: parent.left
                                        leftMargin: theme.padding
                                        right: parent.right
                                        rightMargin: theme.padding
                                        verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.name || ""
                                        elide: Text.ElideRight
                                        color: theme.text
                                        font.family: theme.fontFamily
                                        font.pixelSize: theme.fontSize
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.comment || modelData.genericName || ""
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                        color: theme.muted
                                        font.family: theme.fontFamily
                                        font.pixelSize: 10
                                    }
                                }

                                HoverHandler {
                                    id: hover
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        modelData.execute();
                                        shell.closeLauncher();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
