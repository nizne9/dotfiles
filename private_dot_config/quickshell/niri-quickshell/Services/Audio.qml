import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: service

    property real volume: 0
    property bool isMuted: false
    property var sink: null

    function findDefaultSink() {
        const nodes = Pipewire.nodes;
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i];
            if (node.nodeType !== PwNodeType.Sink)
                continue;
            const audio = node.audio;
            if (!audio)
                continue;
            return node;
        }
        return null;
    }

    function setVolume(val) {
        if (!sink || !sink.audio)
            return;
        sink.audio.volume = Math.max(0, Math.min(1, val));
    }

    function toggleMute() {
        if (!sink || !sink.audio)
            return;
        sink.audio.muted = !sink.audio.muted;
    }

    function updateSink() {
        const s = findDefaultSink();
        if (s !== sink) {
            sink = s;
        }
        if (sink && sink.audio) {
            volume = sink.audio.volume;
            isMuted = sink.audio.muted;
        }
    }

    Connections {
        target: Pipewire
        function onNodesChanged() {
            service.updateSink();
        }
    }

    Connections {
        target: sink ? sink.audio : null
        function onVolumeChanged() {
            if (sink && sink.audio)
                service.volume = sink.audio.volume;
        }
        function onMutedChanged() {
            if (sink && sink.audio)
                service.isMuted = sink.audio.muted;
        }
    }

    Component.onCompleted: updateSink()
}
