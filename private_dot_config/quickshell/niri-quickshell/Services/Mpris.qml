pragma Singleton

import QtQuick
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
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === QsMpris.MprisPlaybackState.Playing) {
                playing = players[i];
                break;
            }
        }

        const target = playing || players[0];
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

    Connections {
        target: currentPlayer
        function onTrackTitleChanged() { service.updateTrackInfo(); }
        function onTrackArtistChanged() { service.updateTrackInfo(); }
        function onTrackArtUrlChanged() { service.updateTrackInfo(); }
        function onPlaybackStateChanged() { service.updateTrackInfo(); }
    }

    Component.onCompleted: selectPlayer()
}
