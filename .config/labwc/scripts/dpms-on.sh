#!/bin/sh

if command -v wlopm >/dev/null 2>&1; then
  exec wlopm --on "*"
fi

exit 0
