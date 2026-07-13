import QtQuick
import Quickshell
import Quickshell.Io
import "../Common"
import "../Widgets"

Rectangle {
    id: root

    required property var entry

    readonly property string cacheDirectory: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/niri-quickshell-clipboard"
    readonly property string cachePath: cacheDirectory + "/" + String(entry.id || "")
    property string imageSource: ""
    property bool failed: false

    width: 76
    height: 54
    radius: Style.radiusS
    color: Theme.surface
    clip: true

    Component.onCompleted: {
        if (/^\d+$/.test(String(entry.id || "")))
            decodeProc.running = true;
        else
            failed = true;
    }

    Component.onDestruction: {
        if (cachePath.length > cacheDirectory.length + 1)
            Quickshell.execDetached(["/usr/bin/rm", "-f", "--", cachePath]);
    }

    Process {
        id: decodeProc
        command: [
            "/usr/bin/bash", "-o", "pipefail", "-c",
            "umask 077; mkdir -p \"$1\"; cliphist decode \"$2\" > \"$3\"",
            "clipboard-image", root.cacheDirectory, String(root.entry.id || ""), root.cachePath
        ]

        onExited: exitCode => {
            if (exitCode === 0)
                root.imageSource = "file://" + root.cachePath;
            else
                root.failed = true;
        }
    }

    Image {
        anchors.fill: parent
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize.width: root.width * 2
        sourceSize.height: root.height * 2
        visible: status === Image.Ready
    }

    Icon {
        anchors.centerIn: parent
        name: root.failed ? "image-broken" : "image"
        size: 18
        color: root.failed ? Theme.urgent : Theme.muted
        visible: root.imageSource.length === 0
    }
}
