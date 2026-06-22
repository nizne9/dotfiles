pragma Singleton

import QtQuick
import Quickshell

// User-configurable label overrides for tray items whose SNI metadata
// is garbage (e.g. Electron apps reporting "chrome_status_icon_1").
//
// To add a new override, append an entry to the array:
//   { iconContains: "keyword", label: "Display Name" }
//   { idEquals: "exact-id",    label: "Display Name" }
//
// iconContains: case-insensitive substring match against item.icon
// idEquals:     exact case-insensitive match against item.id
//
// The first matching entry wins. Items without a match fall through to
// the normal tooltipTitle / title / id fallback chain in TrayOverflowPopup.

Singleton {
    id: root

    readonly property var overrides: [
        // Electron apps — SNI id is "chrome_status_icon_1" for all of them.
        // Match by icon URL keyword (Quickshell serves icons as image:// URLs).
        // Add entries here as you encounter new Electron tray apps.
        // { iconContains: "qq",       label: "QQ" },
        // { iconContains: "wechat",   label: "微信" },
        // { iconContains: "weixin",   label: "微信" },
        // { iconContains: "discord",  label: "Discord" },
    ]

    // Returns a label string if an override matches, or "" if none do.
    function lookup(item) {
        if (!item)
            return "";

        const icon = ((item.icon || "") + "").toLowerCase();
        const id = ((item.id || "") + "").toLowerCase();

        for (let i = 0; i < overrides.length; i++) {
            const entry = overrides[i];
            if (entry.iconContains && icon.indexOf(entry.iconContains.toLowerCase()) !== -1)
                return entry.label;
            if (entry.idEquals && id === entry.idEquals.toLowerCase())
                return entry.label;
        }

        return "";
    }
}
