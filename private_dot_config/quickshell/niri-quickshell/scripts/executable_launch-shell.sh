#!/usr/bin/env bash
set -euo pipefail

plugin_dir="$HOME/.config/quickshell/niri-quickshell/plugins"
export QML_IMPORT_PATH="$plugin_dir${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"

exec qs --no-duplicate -c niri-quickshell "$@"
