pragma Singleton

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

    function snapshot(notification) {
        return {
            id: notification.id,
            appName: notification.appName || notification.app_name || "",
            appIcon: notification.appIcon || "",
            summary: notification.summary || "",
            body: notification.body || "",
            urgency: notification.urgency,
            actions: notification.actions || [],
            notification: notification
        };
    }

    function prependBounded(items, item, maxItems) {
        const filtered = items.filter(i => i.id !== item.id);
        filtered.unshift(item);
        return maxItems > 0 ? filtered.slice(0, maxItems) : [];
    }

    function syncToasts() {
        const now = Date.now();
        toasts = toasts.filter(item => item.expiresAt === 0 || item.expiresAt > now).slice(0, maxToasts);
        scheduleExpiry();
    }

    function scheduleExpiry() {
        let nextExpiresAt = 0;
        for (let i = 0; i < toasts.length; i++) {
            const expiresAt = toasts[i].expiresAt || 0;
            if (expiresAt > 0 && (nextExpiresAt === 0 || expiresAt < nextExpiresAt))
                nextExpiresAt = expiresAt;
        }

        if (nextExpiresAt === 0) {
            expire.stop();
            return;
        }

        expire.interval = Math.max(1, nextExpiresAt - Date.now());
        expire.restart();
    }

    function push(notification) {
        notification.tracked = true;

        const item = snapshot(notification);
        const timeout = timeoutFor(notification.urgency);
        item.expiresAt = timeout > 0 ? Date.now() + timeout : 0;

        toasts = prependBounded(toasts, item, maxToasts);
        history = prependBounded(history, item, maxHistory);
        scheduleExpiry();
    }

    function dismiss(id) {
        const item = history.find(i => i.id === id) || toasts.find(i => i.id === id);
        if (item && item.notification)
            item.notification.dismiss();

        toasts = toasts.filter(i => i.id !== id);
        history = history.filter(i => i.id !== id);
        scheduleExpiry();
    }

    function dismissToast(id) {
        toasts = toasts.filter(i => i.id !== id);
        scheduleExpiry();
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
        expire.stop();
    }

    onMaxToastsChanged: syncToasts()
    onMaxHistoryChanged: history = maxHistory > 0 ? history.slice(0, maxHistory) : []

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
        repeat: false
        onTriggered: service.syncToasts()
    }
}
