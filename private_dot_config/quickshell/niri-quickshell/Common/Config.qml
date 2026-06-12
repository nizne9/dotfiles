pragma Singleton

import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: config

    readonly property int currentVersion: 1
    property bool loaded: false
    property string configPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/niri-quickshell/config.json"

    readonly property alias theme: adapter.theme
    readonly property alias notifications: adapter.notifications
    readonly property int version: adapter.configVersion

    function clampInt(value, min, max, fallback) {
        const number = Number(value);
        if (!Number.isFinite(number))
            return fallback;
        return Math.max(min, Math.min(max, Math.round(number)));
    }

    function migrate() {
        if (adapter.configVersion < 1)
            adapter.configVersion = 1;
    }

    function normalize() {
        migrate();

        adapter.theme.barHeight = clampInt(adapter.theme.barHeight, 20, 96, 34);
        adapter.theme.radius = clampInt(adapter.theme.radius, 0, 32, 8);
        adapter.theme.gap = clampInt(adapter.theme.gap, 0, 32, 8);
        adapter.theme.padding = clampInt(adapter.theme.padding, 0, 48, 10);
        adapter.theme.fontSize = clampInt(adapter.theme.fontSize, 8, 32, 12);

        adapter.notifications.maxToasts = clampInt(adapter.notifications.maxToasts, 1, 10, 3);
        adapter.notifications.maxHistory = clampInt(adapter.notifications.maxHistory, 0, 100, 20);
        adapter.notifications.defaultTimeout = clampInt(adapter.notifications.defaultTimeout, 1000, 60000, 5000);
        adapter.notifications.lowTimeout = clampInt(adapter.notifications.lowTimeout, 1000, 60000, 8000);
        adapter.notifications.criticalTimeout = clampInt(adapter.notifications.criticalTimeout, 0, 60000, 0);
    }

    FileView {
        id: configFile
        path: config.configPath
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter

            property int configVersion: config.currentVersion

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
            config.normalize();
            config.loaded = true;
        }
    }
}
