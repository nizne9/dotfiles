import QtQuick
import Quickshell
import Quickshell.Io
import "Services"
import "Modules"

ShellRoot {
    id: shell

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
        id: niri
    }

    Notifications {
        id: notifications
    }

    IpcHandler {
        target: "shell"

        function toggleLauncher() {
            shell.toggleLauncher();
        }

        function closeLauncher() {
            shell.closeLauncher();
        }

        function toggleNotifications() {
            shell.toggleNotifications();
        }

        function closeNotifications() {
            shell.closeNotifications();
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            screen: modelData
            shell: shell
            niri: niri
            notifications: notifications
        }
    }

    Launcher {
        shell: shell
    }

    NotificationLayer {
        notifications: notifications
    }

    NotificationCenter {
        shell: shell
        notifications: notifications
    }
}
