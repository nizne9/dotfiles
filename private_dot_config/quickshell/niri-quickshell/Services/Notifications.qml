pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../Common"

Scope {
    id: service

    property var toasts: []
    property var history: []
    property bool centerOpen: false
    property bool doNotDisturb: false
    property bool toastsPaused: false
    readonly property int maxToasts: Config.notifications.maxToasts
    readonly property int maxHistory: Config.notifications.maxHistory
    readonly property int unreadCount: history.filter(item => !item.read).length

    function timeoutFor(notification) {
        if (notification.expireTimeout === 0)
            return 0;
        if (notification.expireTimeout > 0)
            return notification.expireTimeout;
        if (notification.urgency === NotificationUrgency.Critical)
            return Config.notifications.criticalTimeout;
        if (notification.urgency === NotificationUrgency.Low)
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
            resident: notification.resident,
            transient: notification.transient,
            desktopEntry: notification.desktopEntry || "",
            image: notification.image || "",
            createdAt: Date.now(),
            read: false,
            notification: notification
        };
    }

    function syncToasts() {
        if (toastsPaused)
            return;

        const now = Date.now();
        const removed = toasts.filter(item => item.expiresAt > 0 && item.expiresAt <= now);
        toasts = toasts.filter(item => item.expiresAt === 0 || item.expiresAt > now).slice(0, maxToasts);
        for (let i = 0; i < removed.length; i++)
            expireIfUnused(removed[i]);
        scheduleExpiry();
    }

    function scheduleExpiry() {
        if (toastsPaused) {
            expire.stop();
            return;
        }

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
        const previous = history.find(i => i.id === item.id);
        if (previous) {
            item.createdAt = previous.createdAt;
            item.read = previous.read;
        }

        const timeout = timeoutFor(notification);
        item.expiresAt = !toastsPaused && timeout > 0 ? Date.now() + timeout : 0;
        item.remainingMs = toastsPaused ? timeout : 0;

        const oldItems = toasts.concat(history).filter(i => i.id === item.id && i.notification !== notification);
        let nextToasts = toasts.filter(i => i.id !== item.id);
        let nextHistory = history.filter(i => i.id !== item.id);
        const showToast = !centerOpen && (!doNotDisturb || item.urgency === NotificationUrgency.Critical);
        if (showToast)
            nextToasts = [item].concat(nextToasts);
        if (!item.transient)
            nextHistory = [item].concat(nextHistory);

        const evictedToasts = nextToasts.slice(maxToasts);
        const evictedHistory = nextHistory.length > maxHistory ? nextHistory.slice(maxHistory) : [];
        toasts = nextToasts.slice(0, maxToasts);
        history = maxHistory > 0 ? nextHistory.slice(0, maxHistory) : [];

        for (let i = 0; i < oldItems.length; i++)
            oldItems[i].notification.tracked = false;
        for (let i = 0; i < evictedToasts.length; i++)
            expireIfUnused(evictedToasts[i]);
        for (let i = 0; i < evictedHistory.length; i++)
            expireIfUnused(evictedHistory[i]);

        const id = item.id;
        notification.closed.connect(reason => service.removeGeneration(id, notification));
        if (!toasts.some(i => i.notification === notification) && !history.some(i => i.notification === notification))
            notification.expire();
        scheduleExpiry();
    }

    function removeGeneration(id, notification) {
        toasts = toasts.filter(i => i.id !== id || i.notification !== notification);
        history = history.filter(i => i.id !== id || i.notification !== notification);
        scheduleExpiry();
    }

    function expireIfUnused(item) {
        if (!item || !item.notification)
            return;
        const stillUsed = toasts.some(i => i.notification === item.notification)
            || history.some(i => i.notification === item.notification);
        if (!stillUsed)
            item.notification.expire();
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

        const item = history.find(i => i.id === id) || toasts.find(i => i.id === id);
        action.invoke();
        if (item && item.resident)
            dismissToast(id);
        else
            dismiss(id);
    }

    function markAllRead() {
        if (unreadCount === 0)
            return;
        history = history.map(item => {
            item.read = true;
            return item;
        });
    }

    function setCenterOpen(open) {
        centerOpen = open;
        if (open) {
            const removed = toasts;
            toasts = [];
            expire.stop();
            for (let i = 0; i < removed.length; i++)
                expireIfUnused(removed[i]);
            markAllRead();
        }
    }

    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb;
        if (!doNotDisturb)
            return;
        const removed = toasts.filter(item => item.urgency !== NotificationUrgency.Critical);
        toasts = toasts.filter(item => item.urgency === NotificationUrgency.Critical);
        for (let i = 0; i < removed.length; i++)
            expireIfUnused(removed[i]);
        scheduleExpiry();
    }

    function pauseToasts() {
        if (toastsPaused)
            return;
        const now = Date.now();
        toasts = toasts.map(item => {
            item.remainingMs = item.expiresAt > 0 ? Math.max(1, item.expiresAt - now) : 0;
            item.expiresAt = 0;
            return item;
        });
        toastsPaused = true;
        expire.stop();
    }

    function resumeToasts() {
        if (!toastsPaused)
            return;
        const now = Date.now();
        toastsPaused = false;
        toasts = toasts.map(item => {
            item.expiresAt = item.remainingMs > 0 ? now + item.remainingMs : 0;
            item.remainingMs = 0;
            return item;
        });
        scheduleExpiry();
    }

    function clearHistory() {
        const items = history.concat(toasts);
        const dismissed = [];
        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            if (item.notification && dismissed.indexOf(item.notification) < 0) {
                dismissed.push(item.notification);
                item.notification.dismiss();
            }
        }
        history = [];
        toasts = [];
        expire.stop();
    }

    onMaxToastsChanged: {
        const removed = toasts.slice(maxToasts);
        toasts = toasts.slice(0, maxToasts);
        for (let i = 0; i < removed.length; i++)
            expireIfUnused(removed[i]);
        syncToasts();
    }
    onMaxHistoryChanged: {
        const removed = maxHistory > 0 ? history.slice(maxHistory) : history;
        history = maxHistory > 0 ? history.slice(0, maxHistory) : [];
        for (let i = 0; i < removed.length; i++)
            expireIfUnused(removed[i]);
    }

    NotificationServer {
        id: server
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        bodyImagesSupported: false
        actionsSupported: true
        actionIconsSupported: false
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => service.push(notification)
    }

    Timer {
        id: expire
        repeat: false
        onTriggered: service.syncToasts()
    }
}
