import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Scope {
    id: service

    property var currentPlayer: null
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackArtUrl: ""
    property bool isPlaying: false

    function selectPlayer() {
        const players = Mpris.players;
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
            if (players[i].playbackState === MprisPlaybackState.Playing) {
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
        isPlaying = currentPlayer.playbackState === MprisPlaybackState.Playing;
    }

    Connections {
        target: Mpris
        function onPlayersChanged() {
            service.selectPlayer();
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
