#!/bin/sh

if command -v wlopm >/dev/null 2>&1; then
  exec wlopm --off "*"
fi

exit 0
