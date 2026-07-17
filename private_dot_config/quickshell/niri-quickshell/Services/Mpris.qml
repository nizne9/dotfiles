pragma Singleton

import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.Mpris as QsMpris

Scope {
    id: service

    property var currentPlayer: null
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackArtUrl: ""
    property bool isPlaying: false

    function selectPlayer() {
        const players = QsMpris.Mpris.players.values;
        if (players.length === 0) {
            currentPlayer = null;
            trackTitle = "";
            trackArtist = "";
            trackArtUrl = "";
            isPlaying = false;
            return;
        }

        let playing = null;
        let currentPresent = false;
        for (let i = 0; i < players.length; i++) {
            if (players[i] === currentPlayer)
                currentPresent = true;
            if (players[i].playbackState === QsMpris.MprisPlaybackState.Playing) {
                if (!playing)
                    playing = players[i];
            }
        }

        const currentIsPlaying = currentPresent
            && currentPlayer.playbackState === QsMpris.MprisPlaybackState.Playing;
        const target = currentIsPlaying ? currentPlayer : (playing || (currentPresent ? currentPlayer : players[0]));
        if (target !== currentPlayer) {
            currentPlayer = target;
        }
        updateTrackInfo();
    }

    function updateTrackInfo() {
        if (!currentPlayer) {
            trackTitle = "";
            trackArtist = "";
            trackArtUrl = "";
            isPlaying = false;
            return;
        }
        trackTitle = currentPlayer.trackTitle || "";
        trackArtist = currentPlayer.trackArtist || "";
        trackArtUrl = currentPlayer.trackArtUrl || "";
        isPlaying = currentPlayer.playbackState === QsMpris.MprisPlaybackState.Playing;
    }

    Connections {
        target: QsMpris.Mpris.players
        function onValuesChanged() { service.selectPlayer(); }
    }

    Instantiator {
        model: QsMpris.Mpris.players

        delegate: Connections {
            required property var modelData
            target: modelData
            function onPlaybackStateChanged() { service.selectPlayer(); }
        }
    }

    Connections {
        target: currentPlayer
        function onTrackTitleChanged() { service.updateTrackInfo(); }
        function onTrackArtistChanged() { service.updateTrackInfo(); }
        function onTrackArtUrlChanged() { service.updateTrackInfo(); }
        function onPlaybackStateChanged() { service.updateTrackInfo(); }
    }

    Component.onCompleted: selectPlayer()
}
