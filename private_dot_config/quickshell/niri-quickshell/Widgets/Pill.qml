pragma Singleton

import QtQuick
import Quickshell
import "../Common"

Singleton {
    id: pill

    function create(parent, text, opts) {
        const options = opts || {};
        const component = Qt.createComponent("PillInstance.qml");
        if (component.status === Component.Ready) {
            const obj = component.createObject(parent, {
                "labelText": text,
                "pillColor": options.color || Theme.surface,
                "pillRadius": options.radius || Theme.radius,
                "pillHeight": options.height || 24,
                "pillWidth": options.width || undefined,
                "textColor": options.textColor || Theme.text,
                "fontSize": options.fontSize || Theme.fontSize
            });
            return obj;
        }
        return null;
    }
}
