#!/usr/bin/env bash
set -euo pipefail

# syncthing.service ships with the package (WantedBy=default.target); only its
# enablement is ours to automate. Device identity, keys and config live in
# ~/.local/state/syncthing and are deliberately unmanaged. Pairing a new
# machine and setting Rime's sync_dir stay manual, one-time, per device.
[ -d /run/systemd/system ] || exit 0
command -v systemctl >/dev/null 2>&1 || exit 0
command -v syncthing >/dev/null 2>&1 || exit 0

systemctl --user enable --now syncthing.service
