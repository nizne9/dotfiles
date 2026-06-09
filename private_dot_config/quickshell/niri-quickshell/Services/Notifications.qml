import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"

Scope {
    id: service

    property var toasts: []
    property var history: []
    readonly property int maxToasts: Config.notifications.maxToasts
    readonly property int maxHistory: Config.notifications.maxHistory

    function timeoutFor(urgency) {
        if (urgency === NotificationUrgency.Critical)
            return Config.notifications.criticalTimeout;
        if (urgency === NotificationUrgency.Low)
            return Config.notifications.lowTimeout;
        return Config.notifications.defaultTimeout;
    }

    function push(notification) {
        notification.tracked = true;

        const item = {
            id: notification.id,
            appName: notification.appName || notification.app_name || "",
            appIcon: notification.appIcon || "",
            summary: notification.summary || "",
            body: notification.body || "",
            urgency: notification.urgency,
            actions: notification.actions || [],
            notification: notification
        };

        toasts = [item].concat(toasts).slice(0, maxToasts);
        history = [item].concat(history).slice(0, maxHistory);

        const timeout = timeoutFor(notification.urgency);
        if (timeout > 0) {
            expire.interval = timeout;
            expire.start();
        }
    }

    function dismiss(id) {
        const item = history.find(i => i.id === id) || toasts.find(i => i.id === id);
        if (item && item.notification)
            item.notification.dismiss();

        toasts = toasts.filter(i => i.id !== id);
        history = history.filter(i => i.id !== id);
    }

    function dismissToast(id) {
        toasts = toasts.filter(i => i.id !== id);
    }

    function invokeAction(id, action) {
        if (!action)
            return;

        action.invoke();
        dismiss(id);
    }

    function clearHistory() {
        for (let i = 0; i < history.length; i++) {
            const item = history[i];
            if (item.notification)
                item.notification.dismiss();
        }
        history = [];
        toasts = [];
    }

    NotificationServer {
        id: server
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: false
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
            if (service.toasts.length > 0) {
                const lastItem = service.toasts[service.toasts.length - 1];
                const nextTimeout = service.timeoutFor(lastItem.urgency);
                if (nextTimeout > 0) {
                    expire.interval = nextTimeout;
                    start();
                }
            }
        }
    }
}
