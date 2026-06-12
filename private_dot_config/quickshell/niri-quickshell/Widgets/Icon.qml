import QtQuick
import "../Common"

Text {
    id: root

    property string name: ""
    property int size: Style.iconSize

    text: glyphFor(name)
    color: Theme.text
    font.family: "Symbols Nerd Font"
    font.pixelSize: size
    font.weight: Font.Normal
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    antialiasing: true

    function glyphFor(iconName) {
        switch (iconName) {
        case "bell":
        case "notifications":
            return "\uf0f3";
        case "bell-off":
        case "notifications-off":
            return "\uf1f6";
        case "play":
            return "\uf04b";
        case "pause":
            return "\uf04c";
        case "volume-high":
            return "\uf028";
        case "volume-muted":
            return "\uf026";
        default:
            return iconName;
        }
    }
}
