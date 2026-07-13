#!/usr/bin/env bash

set -u

types="$(wl-paste --list-types 2>/dev/null || true)"
if [[ "${types,,}" == *"x-kde-passwordmanagerhint"* ]]; then
  exit 0
fi

exec cliphist store
