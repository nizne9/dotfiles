pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: service

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET")

    property var workspaces: []
    property var windows: []
    property int focusedWindowId: -1
    property string focusedWindowTitle: "niri"
    property string focusedOutput: ""

    function handleEvent(line) {
        const text = String(line).trim();
        if (text.length === 0)
            return;

        let event = {};
        try {
            event = JSON.parse(text);
        } catch (error) {
            console.log("niri event parse failed:", error, text);
            return;
        }

        if (event.WorkspacesChanged && event.WorkspacesChanged.workspaces)
            setWorkspaces(event.WorkspacesChanged.workspaces);
        if (event.WindowsChanged && event.WindowsChanged.windows)
            setWindows(event.WindowsChanged.windows);
        if (event.WindowFocusChanged) {
            const id = event.WindowFocusChanged.id;
            focusedWindowId = id === null || id === undefined ? -1 : id;
            updateFocusedWindowTitle();
        }
    }

    function handleRequest(line) {
        const text = String(line).trim();
        if (text.length === 0)
            return;

        let msg = {};
        try {
            msg = JSON.parse(text);
        } catch (error) {
            console.log("niri request parse failed:", error, text);
            return;
        }

        // Synchronous request/response is wrapped in {"Ok": ...}
        if (!msg.Ok)
            return;

        const res = msg.Ok;
        if (res.Workspaces)
            setWorkspaces(res.Workspaces);
        else if (res.Windows)
            setWindows(res.Windows);
    }

    function setWorkspaces(next) {
        const sorted = next.slice().sort((a, b) => {
            const left = a.idx || a.id || 0;
            const right = b.idx || b.id || 0;
            return left - right;
        });
        workspaces = sorted;
        for (let i = 0; i < sorted.length; i++) {
            if (sorted[i].is_focused) {
                focusedOutput = sorted[i].output || "";
                break;
            }
        }
    }

    function setWindows(next) {
        windows = next.slice();
        updateFocusedWindowTitle();
    }

    function updateFocusedWindowTitle() {
        for (let i = 0; i < windows.length; i++) {
            const window = windows[i];
            if (window.id === focusedWindowId || window.is_focused || window.focused) {
                focusedWindowTitle = window.title || window.app_id || "niri";
                return;
            }
        }

        focusedWindowTitle = "niri";
    }

    function focusWorkspace(workspace) {
        const ref = workspace.name || workspace.idx || workspace.id;
        if (ref === undefined || ref === null)
            return;

        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(ref)]);
    }

    function startEventStream() {
        niriEventStream.write('"EventStream"\n');
        niriEventStream.flush();
    }

    function refreshWorkspaces() {
        niriRequestSocket.write('"Workspaces"\n');
        niriRequestSocket.flush();
    }

    function refreshWindows() {
        niriRequestSocket.write('"Windows"\n');
        niriRequestSocket.flush();
    }

    Socket {
        id: niriEventStream
        path: service.socketPath
        connected: service.socketPath.length > 0

        parser: SplitParser {
            onRead: line => service.handleEvent(line)
        }
    }

    Socket {
        id: niriRequestSocket
        path: service.socketPath
        connected: service.socketPath.length > 0

        parser: SplitParser {
            onRead: line => service.handleRequest(line)
        }
    }

    Connections {
        target: niriEventStream
        function onConnectedChanged() {
            if (connected)
                service.startEventStream();
        }
    }

    Connections {
        target: niriRequestSocket
        function onConnectedChanged() {
            if (connected) {
                service.refreshWorkspaces();
                service.refreshWindows();
            }
        }
    }
}
