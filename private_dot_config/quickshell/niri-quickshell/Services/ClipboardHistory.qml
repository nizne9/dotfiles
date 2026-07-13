pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int maxEntries: 300
    property var entries: []
    property bool loading: false
    property bool _refreshPending: false
    property bool _selfCopy: false

    signal entryCopied(string entryId)
    signal entryDeleted(string entryId)
    signal historyCleared()
    signal operationFailed(string message)

    function parseEntry(line) {
        const raw = String(line || "");
        const separator = raw.indexOf("\t");
        if (separator <= 0)
            return null;

        const id = raw.slice(0, separator).trim();
        if (!/^\d+$/.test(id))
            return null;

        const preview = raw.slice(separator + 1).replace(/\u0000/g, "");
        const isImage = /^\[\[\s*binary data\b/i.test(preview);
        const dimensions = isImage ? preview.match(/(\d+)x(\d+)/) : null;
        const format = isImage ? preview.match(/\b(png|jpe?g|webp|gif|bmp|tiff?)\b/i) : null;

        return {
            id: id,
            raw: raw,
            preview: preview,
            isImage: isImage,
            imageWidth: dimensions ? Number(dimensions[1]) : 0,
            imageHeight: dimensions ? Number(dimensions[2]) : 0,
            imageFormat: format ? String(format[1]).toUpperCase() : "IMAGE"
        };
    }

    function refresh() {
        if (readProc.running) {
            _refreshPending = true;
            return;
        }

        readProc.buffer = [];
        loading = true;
        readProc.running = true;
    }

    function copyEntry(entry) {
        if (!entry || !/^\d+$/.test(String(entry.id || "")) || copyProc.running)
            return;

        _selfCopy = true;
        selfCopyReset.restart();
        copyProc.entryId = String(entry.id);
        copyProc.command = [
            "/usr/bin/bash", "-o", "pipefail", "-c",
            "cliphist decode \"$1\" | wl-copy",
            "clipboard-copy", copyProc.entryId
        ];
        copyProc.running = true;
    }

    function deleteEntry(entry) {
        if (!entry || !/^\d+$/.test(String(entry.id || "")) || deleteProc.running)
            return;

        deleteProc.entryId = String(entry.id);
        deleteProc.rawEntry = String(entry.raw || "");
        deleteProc.stdinEnabled = true;
        deleteProc.running = true;
    }

    function clearHistory() {
        if (!wipeProc.running)
            wipeProc.running = true;
    }

    Component.onCompleted: refresh()

    Connections {
        target: Quickshell

        function onClipboardTextChanged() {
            if (root._selfCopy) {
                root._selfCopy = false;
                selfCopyReset.stop();
                return;
            }
            refreshDelay.restart();
        }
    }

    Timer {
        id: refreshDelay
        interval: 500
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: selfCopyReset
        interval: 2000
        repeat: false
        onTriggered: root._selfCopy = false
    }

    Process {
        id: readProc
        property var buffer: []

        command: ["cliphist", "list"]
        stdout: SplitParser {
            onRead: line => readProc.buffer = readProc.buffer.concat([line])
        }

        onExited: exitCode => {
            if (exitCode === 0) {
                const parsed = [];
                const limit = Math.min(readProc.buffer.length, root.maxEntries);
                for (let i = 0; i < limit; i++) {
                    const entry = root.parseEntry(readProc.buffer[i]);
                    if (entry)
                        parsed.push(entry);
                }
                root.entries = parsed;
            } else {
                root.operationFailed("Could not read clipboard history");
            }

            root.loading = false;
            if (root._refreshPending) {
                root._refreshPending = false;
                Qt.callLater(root.refresh);
            }
        }
    }

    Process {
        id: copyProc
        property string entryId: ""

        onExited: exitCode => {
            if (exitCode === 0)
                root.entryCopied(entryId);
            else {
                root._selfCopy = false;
                selfCopyReset.stop();
                root.operationFailed("Could not copy clipboard entry");
            }
            entryId = "";
        }
    }

    Process {
        id: deleteProc
        property string entryId: ""
        property string rawEntry: ""

        command: ["cliphist", "delete"]
        stdinEnabled: true

        onRunningChanged: {
            if (!running)
                return;
            write(rawEntry + "\n");
            stdinEnabled = false;
        }

        onExited: exitCode => {
            const deletedId = entryId;
            entryId = "";
            rawEntry = "";
            stdinEnabled = true;
            if (exitCode === 0) {
                root.entryDeleted(deletedId);
                root.refresh();
            } else {
                root.operationFailed("Could not delete clipboard entry");
            }
        }
    }

    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]

        onExited: exitCode => {
            if (exitCode === 0) {
                root.entries = [];
                root.historyCleared();
            } else {
                root.operationFailed("Could not clear clipboard history");
            }
        }
    }
}
