import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: service

    property var toasts: []
    property var history: []
    readonly property int maxToasts: 3
    readonly property int maxHistory: 20

    function push(notification) {
        notification.tracked = true;

        const item = {
            id: notification.id,
            appName: notification.appName || notification.app_name || "",
            summary: notification.summary || "",
            body: notification.body || "",
            notification: notification
        };

        toasts = [item].concat(toasts).slice(0, maxToasts);
        history = [item].concat(history).slice(0, maxHistory);
        expire.start();
    }

    function dismiss(id) {
        toasts = toasts.filter(item => item.id !== id);
    }

    function clearHistory() {
        history = [];
    }

    NotificationServer {
        id: server
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        persistenceSupported: true

        onNotification: notification => service.push(notification)
    }

    Timer {
        id: expire
        interval: 5000
        repeat: false
        onTriggered: {
            if (service.toasts.length > 0)
                service.toasts = service.toasts.slice(0, service.toasts.length - 1);
            if (service.toasts.length > 0)
                start();
        }
    }
}
