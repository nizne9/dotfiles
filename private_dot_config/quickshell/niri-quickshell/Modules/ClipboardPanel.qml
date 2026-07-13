import QtQuick
import Quickshell
import Quickshell.Wayland
import "../Common"
import "../Services"
import "../Widgets"

PanelWindow {
    id: panel

    property var shell
    property string query: ""
    property int selectedIndex: 0
    property var filteredEntries: []
    property bool confirmClear: false
    property string statusMessage: ""

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: shell.clipboardVisible
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function refilter() {
        const needle = query.trim().toLowerCase();
        const source = ClipboardHistory.entries || [];
        if (needle.length === 0) {
            filteredEntries = source.slice();
        } else {
            filteredEntries = source.filter(entry => String(entry.preview || "").toLowerCase().indexOf(needle) >= 0);
        }

        if (filteredEntries.length === 0)
            selectedIndex = 0;
        else if (selectedIndex >= filteredEntries.length)
            selectedIndex = filteredEntries.length - 1;
    }

    function moveSelection(delta) {
        const count = filteredEntries.length;
        if (count === 0)
            return;
        selectedIndex = (selectedIndex + delta + count) % count;
        list.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function copyEntry(entry) {
        statusMessage = "";
        ClipboardHistory.copyEntry(entry);
    }

    function copySelected() {
        if (selectedIndex >= 0 && selectedIndex < filteredEntries.length)
            copyEntry(filteredEntries[selectedIndex]);
    }

    function deleteEntry(entry) {
        statusMessage = "";
        ClipboardHistory.deleteEntry(entry);
    }

    function deleteSelected() {
        if (selectedIndex >= 0 && selectedIndex < filteredEntries.length)
            deleteEntry(filteredEntries[selectedIndex]);
    }

    function imageDetails(entry) {
        const dimensions = entry.imageWidth > 0 && entry.imageHeight > 0
            ? entry.imageWidth + " x " + entry.imageHeight
            : "";
        return dimensions.length > 0 ? entry.imageFormat + "  " + dimensions : entry.imageFormat;
    }

    onVisibleChanged: {
        if (visible) {
            query = "";
            search.text = "";
            selectedIndex = 0;
            confirmClear = false;
            statusMessage = "";
            ClipboardHistory.refresh();
            refilter();
            Qt.callLater(() => search.forceActiveFocus());
        }
    }

    onQueryChanged: {
        selectedIndex = 0;
        refilter();
    }

    Connections {
        target: ClipboardHistory

        function onEntriesChanged() {
            panel.refilter();
        }

        function onEntryCopied() {
            panel.shell.closeClipboard();
        }

        function onEntryDeleted() {
            panel.statusMessage = "Entry deleted";
        }

        function onHistoryCleared() {
            panel.confirmClear = false;
            panel.statusMessage = "Clipboard history cleared";
            panel.refilter();
        }

        function onOperationFailed(message) {
            panel.statusMessage = message;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#00000066"

        MouseArea {
            anchors.fill: parent
            onClicked: panel.shell.closeClipboard()
        }

        Rectangle {
            width: Math.min(parent.width - 48, 760)
            height: Math.min(parent.height - 96, 620)
            anchors {
                top: parent.top
                topMargin: 70
                horizontalCenter: parent.horizontalCenter
            }
            radius: Theme.radius
            color: Theme.background
            border.color: Theme.border
            border.width: 1

            Item {
                anchors.fill: parent
                anchors.margins: Theme.padding

                Row {
                    id: searchRow
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                    height: 38
                    spacing: Theme.gap

                    Rectangle {
                        width: parent.width - clearButton.width - parent.spacing
                        height: parent.height
                        radius: Theme.radius
                        color: Theme.surface

                        Icon {
                            anchors {
                                left: parent.left
                                leftMargin: Theme.padding
                                verticalCenter: parent.verticalCenter
                            }
                            name: "search"
                            size: 15
                            color: Theme.muted
                        }

                        TextInput {
                            id: search
                            anchors.fill: parent
                            anchors.leftMargin: 36
                            anchors.rightMargin: Theme.padding
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.text
                            selectionColor: Theme.accent
                            selectedTextColor: Theme.background
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            text: panel.query
                            onTextChanged: panel.query = text

                            Keys.onEscapePressed: {
                                if (panel.confirmClear)
                                    panel.confirmClear = false;
                                else
                                    panel.shell.closeClipboard();
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Up) {
                                    panel.moveSelection(-1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    panel.moveSelection(1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    panel.copySelected();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Delete) {
                                    panel.deleteSelected();
                                    event.accepted = true;
                                }
                            }
                        }

                        Text {
                            visible: search.text.length === 0
                            anchors {
                                left: parent.left
                                leftMargin: 36
                                verticalCenter: parent.verticalCenter
                            }
                            text: "Search clipboard history"
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                        }
                    }

                    Rectangle {
                        id: clearButton
                        width: 38
                        height: 38
                        radius: Theme.radius
                        color: clearHover.hovered ? Theme.surfaceElevated : Theme.surface
                        opacity: ClipboardHistory.entries.length > 0 ? 1 : 0.45

                        Icon {
                            anchors.centerIn: parent
                            name: "trash"
                            size: 15
                            color: Theme.urgent
                        }

                        HoverHandler { id: clearHover }

                        MouseArea {
                            anchors.fill: parent
                            enabled: ClipboardHistory.entries.length > 0
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: panel.confirmClear = true
                        }
                    }
                }

                Rectangle {
                    id: clearConfirmation
                    visible: panel.confirmClear
                    height: visible ? 38 : 0
                    anchors {
                        top: searchRow.bottom
                        topMargin: visible ? Theme.gap : 0
                        left: parent.left
                        right: parent.right
                    }
                    radius: Theme.radius
                    color: Theme.surface
                    border.color: Theme.urgent
                    border.width: 1

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.padding
                            verticalCenter: parent.verticalCenter
                        }
                        text: "Clear all clipboard history?"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    Row {
                        anchors {
                            right: parent.right
                            rightMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 4

                        Rectangle {
                            width: 64
                            height: 28
                            radius: Style.radiusS
                            color: cancelHover.hovered ? Theme.surfaceElevated : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "Cancel"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }

                            HoverHandler { id: cancelHover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: panel.confirmClear = false
                            }
                        }

                        Rectangle {
                            width: 64
                            height: 28
                            radius: Style.radiusS
                            color: confirmHover.hovered ? Theme.urgent : Theme.surfaceElevated

                            Text {
                                anchors.centerIn: parent
                                text: "Clear"
                                color: confirmHover.hovered ? Theme.background : Theme.urgent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }

                            HoverHandler { id: confirmHover }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: ClipboardHistory.clearHistory()
                            }
                        }
                    }
                }

                ListView {
                    id: list
                    anchors {
                        top: clearConfirmation.bottom
                        topMargin: Theme.gap
                        left: parent.left
                        right: parent.right
                        bottom: footer.top
                        bottomMargin: Theme.gap
                    }
                    clip: true
                    spacing: 4
                    currentIndex: panel.selectedIndex
                    cacheBuffer: 180
                    model: ScriptModel {
                        values: panel.filteredEntries
                    }

                    delegate: Rectangle {
                        id: entryRow

                        width: list.width
                        height: modelData.isImage ? 74 : 56
                        radius: Theme.radius
                        color: index === panel.selectedIndex || rowHover.hovered ? Theme.surfaceElevated : Theme.background

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.copyEntry(modelData)
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: Theme.padding
                                rightMargin: Theme.padding
                                topMargin: 6
                                bottomMargin: 6
                            }
                            spacing: Theme.gap

                            Loader {
                                id: previewLoader
                                visible: modelData.isImage
                                width: visible ? 76 : 0
                                height: parent.height
                                anchors.verticalCenter: parent.verticalCenter
                                sourceComponent: imagePreview
                            }

                            Component {
                                id: imagePreview
                                ClipboardImage { entry: modelData }
                            }

                            Column {
                                width: parent.width - previewLoader.width - actionRow.width - Theme.gap * (previewLoader.visible ? 2 : 1)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 3

                                Text {
                                    width: parent.width
                                    text: modelData.isImage ? "Image" : (modelData.preview || "")
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    textFormat: Text.PlainText
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.isImage ? panel.imageDetails(modelData) : "Text"
                                    elide: Text.ElideRight
                                    color: Theme.muted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    textFormat: Text.PlainText
                                }
                            }

                            Row {
                                id: actionRow
                                width: 64
                                height: 28
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                opacity: entryRowHover.hovered || index === panel.selectedIndex ? 1 : 0

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: Style.radiusS
                                    color: copyHover.hovered ? Theme.surface : "transparent"

                                    Icon {
                                        anchors.centerIn: parent
                                        name: "copy"
                                        size: 14
                                        color: Theme.accent
                                    }

                                    HoverHandler { id: copyHover }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: panel.copyEntry(modelData)
                                    }
                                }

                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: Style.radiusS
                                    color: deleteHover.hovered ? Theme.surface : "transparent"

                                    Icon {
                                        anchors.centerIn: parent
                                        name: "trash"
                                        size: 14
                                        color: Theme.urgent
                                    }

                                    HoverHandler { id: deleteHover }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: panel.deleteEntry(modelData)
                                    }
                                }
                            }
                        }

                        HoverHandler {
                            id: rowHover
                            onHoveredChanged: if (hovered) panel.selectedIndex = index
                        }

                        HoverHandler { id: entryRowHover }
                    }
                }

                Column {
                    visible: !ClipboardHistory.loading && panel.filteredEntries.length === 0
                    anchors.centerIn: list

                    Text {
                        text: panel.query.trim().length > 0 ? "No matching entries" : "Clipboard history is empty"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                    }
                }

                Text {
                    visible: ClipboardHistory.loading && panel.filteredEntries.length === 0
                    anchors.centerIn: list
                    text: "Loading clipboard history"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                }

                Row {
                    id: footer
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: 18

                    Text {
                        width: parent.width / 2
                        text: panel.filteredEntries.length + (panel.filteredEntries.length === 1 ? " entry" : " entries")
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }

                    Text {
                        width: parent.width / 2
                        horizontalAlignment: Text.AlignRight
                        text: panel.statusMessage
                        elide: Text.ElideRight
                        color: panel.statusMessage.indexOf("Could not") === 0 ? Theme.urgent : Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
