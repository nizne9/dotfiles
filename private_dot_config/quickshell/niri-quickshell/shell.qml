import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Services"
import "Modules"

ShellRoot {
    id: root

    property bool uiReady: Config.loaded
    property bool launcherVisible: false
    property bool notificationsVisible: false

    function toggleLauncher() {
        launcherVisible = !launcherVisible;
        if (launcherVisible)
            notificationsVisible = false;
    }

    function closeLauncher() {
        launcherVisible = false;
    }

    function toggleNotifications() {
        notificationsVisible = !notificationsVisible;
        if (notificationsVisible)
            launcherVisible = false;
    }

    function closeNotifications() {
        notificationsVisible = false;
    }

    IpcHandler {
        target: "shell"

        function toggleLauncher() {
            root.toggleLauncher();
        }

        function closeLauncher() {
            root.closeLauncher();
        }

        function toggleNotifications() {
            root.toggleNotifications();
        }

        function closeNotifications() {
            root.closeNotifications();
        }

        function lock() {
            if (lockScreenLoader.item)
                lockScreenLoader.item.locked = true;
        }

        function volumeUp() {
            Audio.setVolume(Audio.volume + 0.05);
        }

        function volumeDown() {
            Audio.setVolume(Audio.volume - 0.05);
        }

        function toggleMute() {
            Audio.toggleMute();
        }
    }

    Variants {
        model: root.uiReady ? Quickshell.screens : []

        Scope {
            id: screenDelegate

            required property var modelData

            Bar {
                screen: screenDelegate.modelData
                shell: root
            }
        }
    }

    Loader {
        active: root.uiReady

        sourceComponent: Launcher {
            shell: root
        }
    }

    Loader {
        active: root.uiReady
        sourceComponent: NotificationLayer {
        }
    }

    Loader {
        id: osdLoader
        active: root.uiReady

        sourceComponent: OSD {
            id: osdPanel
        }
    }

    Loader {
        id: lockScreenLoader
        active: root.uiReady
        sourceComponent: LockScreen {
            id: lockScreen
        }
    }

    Connections {
        target: Audio
        function onVolumeChanged() {
            if (osdLoader.active && osdLoader.item)
                osdLoader.item.show("", Audio.volume, Audio.isMuted ? "M" : "V");
        }
        function onIsMutedChanged() {
            if (osdLoader.active && osdLoader.item)
                osdLoader.item.show(Audio.isMuted ? "Muted" : "Unmuted", Audio.volume, Audio.isMuted ? "M" : "V");
        }
    }
}
