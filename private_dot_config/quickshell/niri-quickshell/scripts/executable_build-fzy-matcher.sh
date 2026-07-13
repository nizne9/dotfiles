#!/usr/bin/env bash
set -euo pipefail

if command -v chezmoi >/dev/null 2>&1; then
  source_dir="$(chezmoi source-path ~/.config/quickshell/niri-quickshell/native/fzy-matcher)"
else
  source_dir="$HOME/.local/share/chezmoi/private_dot_config/quickshell/niri-quickshell/native/fzy-matcher"
fi

qt_version="$(pkg-config --modversion Qt6Core)"
build_dir="${XDG_CACHE_HOME:-$HOME/.cache}/niri-quickshell/fzy-matcher-build/qt-${qt_version}"
install_dir="$HOME/.config/quickshell/niri-quickshell/plugins"

cmake -S "$source_dir" -B "$build_dir" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build "$build_dir" --parallel
cmake --install "$build_dir" --prefix "$install_dir"
