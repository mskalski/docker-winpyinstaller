#!/bin/sh

WINEDEBUG=-all
WINEPATH='c:\swigwin;c:\upx'
export WINEDEBUG WINEPATH

wine "$@"
status=$?

if ps | grep wineserver | grep -vq grep >/dev/null; then
  echo -n "Waiting for wineserver to terminate.." 1>&2

  while ps | grep wineserver | grep -vq grep >/dev/null; do
    echo -n "." 1>&2
    sleep 2
  done
fi

echo "DONE" 1>&2

exit $status

