pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: service

    property real volume: 0
    property bool isMuted: false
    property int osdSuppressionCount: 0
    readonly property bool osdSuppressed: osdSuppressionCount > 0
    property var sink: Pipewire.ready ? Pipewire.defaultAudioSink : null

    PwObjectTracker {
        objects: service.sink ? [service.sink] : []
    }

    function setVolume(val) {
        if (!sink || !sink.ready || !sink.audio)
            return;
        sink.audio.volume = Math.max(0, Math.min(1, val));
    }

    function toggleMute() {
        if (!sink || !sink.ready || !sink.audio)
            return;
        sink.audio.muted = !sink.audio.muted;
    }

    function updateSink() {
        var s = Pipewire.defaultAudioSink;
        if (s !== sink) {
            sink = s;
        }
        if (sink && sink.ready && sink.audio) {
            volume = sink.audio.volume;
            isMuted = sink.audio.muted;
        }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() { service.updateSink(); }
        function onReadyChanged() { service.updateSink(); }
    }

    Connections {
        target: sink
        function onReadyChanged() { service.updateSink(); }
    }

    Connections {
        target: sink && sink.ready ? sink.audio : null
        function onVolumesChanged() {
            if (sink && sink.ready && sink.audio)
                service.volume = sink.audio.volume;
        }
        function onMutedChanged() {
            if (sink && sink.ready && sink.audio)
                service.isMuted = sink.audio.muted;
        }
    }

    Component.onCompleted: updateSink()
}