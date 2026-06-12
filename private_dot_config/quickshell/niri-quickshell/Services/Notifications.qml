pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"

Scope {
    id: service

    property var toasts: []
    property var history: []
    readonly property int maxToasts: Config.notifications ? valueOrDefault(Config.notifications.maxToasts, 3) : 3
    readonly property int maxHistory: Config.notifications ? valueOrDefault(Config.notifications.maxHistory, 20) : 20

    function valueOrDefault(value, defaultValue) {
        return value === undefined || value === null ? defaultValue : value;
    }

    function timeoutFor(urgency) {
        var cfg = Config.notifications;
        if (!cfg)
            return 5000;
        if (urgency === NotificationUrgency.Critical)
            return valueOrDefault(cfg.criticalTimeout, 0);
        if (urgency === NotificationUrgency.Low)
            return valueOrDefault(cfg.lowTimeout, 8000);
        return valueOrDefault(cfg.defaultTimeout, 5000);
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
