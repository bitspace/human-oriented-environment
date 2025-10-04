#!/bin/sh
# Idle handler mirroring the Hypridle behaviour under Labwc.

if ! command -v swayidle >/dev/null 2>&1; then
  echo "[labwc] swayidle not installed; skipping idle manager" >&2
  exit 0
fi

if command -v wlopm >/dev/null 2>&1; then
  dpms_off_cmd='wlopm --off "*"'
  dpms_on_cmd='wlopm --on "*"'
else
  dpms_off_cmd=''
  dpms_on_cmd=''
fi

idle_args="-w"

if [ -n "${dpms_off_cmd}" ]; then
  idle_args="${idle_args} timeout 1800 ${dpms_off_cmd} resume ${dpms_on_cmd}"
fi

idle_args="${idle_args} timeout 2400 gtklock"
idle_args="${idle_args} before-sleep loginctl lock-session"

# shellcheck disable=SC2086
exec swayidle ${idle_args}
