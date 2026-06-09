import QtQuick
import "../Common"

Rectangle {
    id: pill

    property string labelText: ""
    property color pillColor: Theme.surface
    property color textColor: Theme.text
    property int fontSize: Theme.fontSize
    property real pillRadius: Theme.radius
    property real pillHeight: 24

    height: pillHeight
    width: implicitWidth > 0 ? implicitWidth : pillHeight
    radius: pillRadius
    color: pillColor

    implicitWidth: pillText.implicitWidth + Theme.padding * 2

    Text {
        id: pillText
        anchors.centerIn: parent
        text: pill.labelText
        color: pill.textColor
        font.family: Theme.fontFamily
        font.pixelSize: pill.fontSize
    }
}
