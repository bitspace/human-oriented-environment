#!/bin/sh
# Idle handler mirroring the Hypridle behaviour under Labwc.

if ! command -v swayidle >/dev/null 2>&1; then
  echo "[labwc] swayidle not installed; skipping idle manager" >&2
  exit 0
fi

locker_cmd="${HOME}/.config/labwc/scripts/lock-screen.sh"
if [ ! -x "${locker_cmd}" ]; then
  locker_cmd="gtklock"
fi

# Build the swayidle argument list safely as an array.
set -- -w

dpms_off_cmd="${HOME}/.config/labwc/scripts/dpms-off.sh"
dpms_on_cmd="${HOME}/.config/labwc/scripts/dpms-on.sh"
if [ -x "${dpms_off_cmd}" ] && [ -x "${dpms_on_cmd}" ]; then
  set -- "$@" timeout 1800 "$dpms_off_cmd" resume "$dpms_on_cmd"
fi

set -- "$@" lock "$locker_cmd"
set -- "$@" timeout 2400 "$locker_cmd"
set -- "$@" before-sleep "loginctl lock-session"

# Ensure we lock immediately when swayidle terminates (e.g. crash)
set -- "$@" idlehint 2400

exec swayidle "$@"
