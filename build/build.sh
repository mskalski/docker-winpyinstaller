#!/bin/bash

tag_arg='-t winpyinstaller'

if echo "$@" | grep ' -t\>\| --tag\>'; then
  # Don't add default tag if some other tags are provided
  tag_arg=''
fi

cd `dirname $0`
docker build --rm=true $tag_arg . "$@"
