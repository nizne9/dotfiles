import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../Common"

WlSessionLock {
    id: lockScreen

    property string password: ""
    property string message: ""
    property bool authenticating: false

    WlSessionLockSurface {
        id: lockSurface

        Rectangle {
            anchors.fill: parent
            color: Theme.background

            Column {
                anchors.centerIn: parent
                spacing: Theme.padding

                Text {
                    text: "niri"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 36
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                SystemClock {
                    id: clock
                    precision: SystemClock.Seconds
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "hh:mm")
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 48
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: 280
                    height: 40
                    radius: Theme.radius
                    color: Theme.surface
                    anchors.horizontalCenter: parent.horizontalCenter

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.margins: Theme.padding
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        echoMode: TextInput.Password
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        focus: true
                        enabled: !lockScreen.authenticating
                        onTextChanged: lockScreen.password = text
                        Keys.onReturnPressed: lockScreen.authenticate()
                        Keys.onEscapePressed: {
                            lockScreen.password = "";
                            text = "";
                        }
                    }

                    Text {
                        visible: passwordInput.text.length === 0
                        anchors {
                            left: parent.left
                            leftMargin: Theme.padding
                            verticalCenter: parent.verticalCenter
                        }
                        text: lockScreen.authenticating ? "Authenticating..." : "Password"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                    }
                }

                Text {
                    text: lockScreen.message
                    color: Theme.urgent
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    visible: text.length > 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    function authenticate() {
        if (password.length === 0 || authenticating)
            return;

        authenticating = true;
        message = "";

        pamAuth.start();
    }

    onLockedChanged: {
        if (locked) {
            password = "";
            message = "";
            authenticating = false;
        }
    }

    PamContext {
        id: pamAuth
        config: "login"

        onPamMessage: {
            if (pamAuth.responseRequired) {
                pamAuth.respond(lockScreen.password);
            }
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                lockScreen.locked = false;
                lockScreen.password = "";
                lockScreen.authenticating = false;
                lockScreen.message = "";
            } else {
                lockScreen.message = "Authentication failed";
                lockScreen.password = "";
                lockScreen.authenticating = false;
                passwordInput.text = "";
                Qt.callLater(() => passwordInput.forceActiveFocus());
            }
        }

        onError: errorType => {
            lockScreen.message = "PAM error";
            lockScreen.authenticating = false;
        }
    }
}
