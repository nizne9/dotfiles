import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: service

    property var workspaces: []
    property var windows: []
    property int focusedWindowId: -1
    property string focusedWindowTitle: "niri"

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

    function setWorkspaces(next) {
        const sorted = next.slice().sort((a, b) => {
            const left = a.idx || a.id || 0;
            const right = b.idx || b.id || 0;
            return left - right;
        });
        workspaces = sorted;
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

    Process {
        id: eventStream
        running: true
        command: ["niri", "msg", "-j", "event-stream"]

        stdout: SplitParser {
            onRead: data => service.handleEvent(data)
        }

        stderr: SplitParser {
            onRead: data => console.log("niri:", data)
        }

        onRunningChanged: {
            if (!running)
                restart.start();
        }
    }

    Timer {
        id: restart
        interval: 2500
        repeat: false
        onTriggered: eventStream.running = true
    }

    Process {
        id: initWorkspaces
        running: true
        command: ["niri", "msg", "-j", "workspaces"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    if (data instanceof Array)
                        service.setWorkspaces(data);
                } catch (e) {
                    console.log("niri init workspaces failed:", e);
                }
            }
        }
    }

    Process {
        id: initWindows
        running: true
        command: ["niri", "msg", "-j", "windows"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    if (data instanceof Array)
                        service.setWindows(data);
                } catch (e) {
                    console.log("niri init windows failed:", e);
                }
            }
        }
    }
}
