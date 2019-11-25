#!/bin/sh -e

appname=`basename "$0" .exe`
name=`echo $appname | cut -d- -f1`

if [ "X$1" = "X--wait" ]; then
  shift
  exec winew "$name.exe" "$@"
  echo "Failed to run using winew" 1>&2
fi

exec wine "$name.exe" "$@"

