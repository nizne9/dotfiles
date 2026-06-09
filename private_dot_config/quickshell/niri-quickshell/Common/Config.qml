pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config

    property string configPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/niri-quickshell/config.json"

    property var theme: ({})
    property var notifications: ({})

    FileView {
        path: config.configPath
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            property JsonObject theme: JsonObject {
                property color background: "#1e1e2e"
                property color surface: "#313244"
                property color surfaceElevated: "#45475a"
                property color text: "#cdd6f4"
                property color muted: "#a6adc8"
                property color accent: "#b4befe"
                property color urgent: "#fab387"
                property color border: "#585b70"
                property int barHeight: 34
                property int radius: 8
                property int gap: 8
                property int padding: 10
                property string fontFamily: "Inter"
                property int fontSize: 12
            }

            property JsonObject notifications: JsonObject {
                property int maxToasts: 3
                property int maxHistory: 20
                property int defaultTimeout: 5000
                property int lowTimeout: 8000
                property int criticalTimeout: 0
            }
        }

        onAdapterUpdated: writeAdapter()
        onLoaded: {
            config.theme = adapter.theme;
            config.notifications = adapter.notifications;
        }
    }
}
