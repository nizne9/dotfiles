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
        if (event.WorkspaceActivated)
            activateWorkspace(event.WorkspaceActivated.id, event.WorkspaceActivated.focused);
        if (event.WorkspaceActiveWindowChanged)
            setWorkspaceActiveWindow(event.WorkspaceActiveWindowChanged.workspace_id,
                event.WorkspaceActiveWindowChanged.active_window_id);
        if (event.WindowsChanged && event.WindowsChanged.windows)
            setWindows(event.WindowsChanged.windows);
        if (event.WindowOpenedOrChanged)
            upsertWindow(event.WindowOpenedOrChanged.window);
        if (event.WindowClosed)
            removeWindow(event.WindowClosed.id);
        if (event.WindowFocusChanged)
            setFocusedWindow(event.WindowFocusChanged.id);
    }

    function setWorkspaces(next) {
        const sorted = next.slice().sort((a, b) => {
            const left = a.idx || a.id || 0;
            const right = b.idx || b.id || 0;
            return left - right;
        });
        workspaces = sorted;
        focusedOutput = "";
        for (let i = 0; i < sorted.length; i++) {
            if (sorted[i].is_focused) {
                focusedOutput = sorted[i].output || "";
                break;
            }
        }
    }

    function activateWorkspace(id, focused) {
        const target = workspaces.find(workspace => workspace.id === id);
        if (!target)
            return;

        workspaces = workspaces.map(workspace => {
            const copy = Object.assign({}, workspace);
            if (workspace.output === target.output)
                copy.is_active = workspace.id === id;
            if (focused)
                copy.is_focused = workspace.id === id;
            return copy;
        });
        if (focused)
            focusedOutput = target.output || "";
    }

    function setWorkspaceActiveWindow(workspaceId, windowId) {
        workspaces = workspaces.map(workspace => {
            if (workspace.id !== workspaceId)
                return workspace;
            const copy = Object.assign({}, workspace);
            copy.active_window_id = windowId;
            return copy;
        });
    }

    function setWindows(next) {
        windows = next.slice();
        const focused = windows.find(window => window.is_focused);
        focusedWindowId = focused ? focused.id : -1;
        updateFocusedWindowTitle();
    }

    function upsertWindow(window) {
        if (!window)
            return;

        const next = windows.filter(item => item.id !== window.id);
        next.push(window);
        windows = window.is_focused
            ? next.map(item => Object.assign({}, item, { is_focused: item.id === window.id }))
            : next;
        if (window.is_focused)
            focusedWindowId = window.id;
        updateFocusedWindowTitle();
    }

    function removeWindow(id) {
        windows = windows.filter(window => window.id !== id);
        if (focusedWindowId === id)
            focusedWindowId = -1;
        updateFocusedWindowTitle();
    }

    function setFocusedWindow(id) {
        focusedWindowId = id === null || id === undefined ? -1 : id;
        windows = windows.map(window => Object.assign({}, window, {
            is_focused: window.id === focusedWindowId
        }));
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

    Socket {
        id: niriEventStream
        path: service.socketPath
        connected: service.socketPath.length > 0

        parser: SplitParser {
            onRead: line => service.handleEvent(line)
        }
    }

    Connections {
        target: niriEventStream
        function onConnectedChanged() {
            if (connected)
                service.startEventStream();
        }
    }
}
