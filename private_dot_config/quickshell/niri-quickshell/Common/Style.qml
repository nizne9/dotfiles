pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Animation durations are in Anims.qml. This file holds non-animation tokens.

    // Spacing scale (independent of Theme; Theme only owns color + base font)
    readonly property int gapXS: 4
    readonly property int gapS: 6
    readonly property int gapM: 8
    readonly property int gapL: 12
    readonly property int gapXL: 16

    // Padding
    readonly property int paddingS: 6
    readonly property int paddingM: 10
    readonly property int paddingL: 14

    // Standard widget dimensions
    readonly property int widgetHeight: 24
    readonly property int widgetHeightLarge: 38
    readonly property int iconSize: 16
    readonly property int iconSizeLarge: 28
    readonly property int avatarSize: 24

    // Bar-specific sizing. Keep bar density decisions centralized here instead
    // of scattering 24/16/6-style constants through Modules/Bar.qml.
    readonly property int barItemHeight: widgetHeight
    readonly property int barIconButtonSize: widgetHeight
    readonly property int barIconSize: iconSize
    readonly property int barAudioWidth: 70
    readonly property int barWorkspaceWidth: 26
    readonly property int barClockWidth: 76
    readonly property int barGroupSpacing: gapM
    readonly property int barItemSpacing: gapXS
    readonly property int barTrayInnerPadding: paddingS
    readonly property int trayOverflowWidth: 34
    readonly property int trayOverflowGridColumns: 5
    readonly property int trayOverflowCellSize: 26
    readonly property int trayOverflowMaxVisibleRows: 8
    readonly property int statusDotSize: 5

    // Panel dimensions
    readonly property int panelWidthS: 280
    readonly property int panelWidthM: 300
    readonly property int panelWidthL: 360

    // Re-export Theme radius with derived sizes
    readonly property int radius: Theme.radius
    readonly property int radiusS: Math.max(4, Math.round(Theme.radius * 0.75))
    readonly property int radiusL: Math.round(Theme.radius * 1.5)
}
