pragma Singleton

import QtQuick
import Quickshell

Singleton {
    function valueOrDefault(value, defaultValue) {
        return value === undefined || value === null ? defaultValue : value;
    }

    readonly property color background: valueOrDefault(Config.theme.background, "#1e1e2e")
    readonly property color surface: valueOrDefault(Config.theme.surface, "#313244")
    readonly property color surfaceElevated: valueOrDefault(Config.theme.surfaceElevated, "#45475a")
    readonly property color text: valueOrDefault(Config.theme.text, "#cdd6f4")
    readonly property color muted: valueOrDefault(Config.theme.muted, "#a6adc8")
    readonly property color accent: valueOrDefault(Config.theme.accent, "#b4befe")
    readonly property color urgent: valueOrDefault(Config.theme.urgent, "#fab387")
    readonly property color border: valueOrDefault(Config.theme.border, "#585b70")

    readonly property int barHeight: valueOrDefault(Config.theme.barHeight, 34)
    readonly property int radius: valueOrDefault(Config.theme.radius, 8)
    readonly property int gap: valueOrDefault(Config.theme.gap, 8)
    readonly property int padding: valueOrDefault(Config.theme.padding, 10)

    readonly property string fontFamily: valueOrDefault(Config.theme.fontFamily, "Inter")
    readonly property int fontSize: valueOrDefault(Config.theme.fontSize, 12)
}
