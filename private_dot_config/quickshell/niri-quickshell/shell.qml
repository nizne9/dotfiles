import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Services"
import "Modules"

ShellRoot {
    id: root

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

    Niri {
        id: niriService
    }

    Notifications {
        id: notificationService
    }

    Audio {
        id: audioService
    }

    Mpris {
        id: mprisService
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
            lockScreen.locked = true;
        }

        function volumeUp() {
            audioService.setVolume(audioService.volume + 0.05);
        }

        function volumeDown() {
            audioService.setVolume(audioService.volume - 0.05);
        }

        function toggleMute() {
            audioService.toggleMute();
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            screen: modelData
            shell: root
            niri: niriService
            notifications: notificationService
            audioService: audioService
            mprisService: mprisService
        }
    }

    LazyLoader {
        id: launcherLoader
        activeAsync: root.launcherVisible

        Launcher {
            shell: root
        }
    }

    NotificationLayer {
        notifications: notificationService
    }

    LazyLoader {
        id: osdLoader
        active: true

        OSD {
            id: osdPanel
        }
    }

    LockScreen {
        id: lockScreen
    }

    Connections {
        target: audioService
        function onVolumeChanged() {
            if (osdLoader.active && osdLoader.item)
                osdLoader.item.show("", audioService.volume, audioService.isMuted ? "M" : "V");
        }
        function onIsMutedChanged() {
            if (osdLoader.active && osdLoader.item)
                osdLoader.item.show(audioService.isMuted ? "Muted" : "Unmuted", audioService.volume, audioService.isMuted ? "M" : "V");
        }
    }
}
