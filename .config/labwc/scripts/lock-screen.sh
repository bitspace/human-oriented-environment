#!/bin/sh
# Wrapper that launches gtklock only if not already running, so multiple triggers don't race.

if ! command -v gtklock >/dev/null 2>&1; then
  echo "[labwc] gtklock not installed; cannot lock screen" >&2
  exit 1
fi

if pgrep -x gtklock >/dev/null 2>&1; then
  exit 0
fi

exec gtklock "$@"
