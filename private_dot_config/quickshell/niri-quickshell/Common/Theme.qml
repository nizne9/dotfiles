pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property color background: Config.theme.background
    readonly property color surface: Config.theme.surface
    readonly property color surfaceElevated: Config.theme.surfaceElevated
    readonly property color text: Config.theme.text
    readonly property color muted: Config.theme.muted
    readonly property color accent: Config.theme.accent
    readonly property color urgent: Config.theme.urgent
    readonly property color border: Config.theme.border

    readonly property int barHeight: Config.theme.barHeight
    readonly property int radius: Config.theme.radius
    readonly property int gap: Config.theme.gap
    readonly property int padding: Config.theme.padding

    readonly property string fontFamily: Config.theme.fontFamily
    readonly property int fontSize: Config.theme.fontSize
}
