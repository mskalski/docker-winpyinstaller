#!/bin/sh

echo "$0 $@"


get_arg_by_name()
{
  name="$1"
  found=0
  shift
  
  
  while [ "$#" -gt 0 ]; do
    if [ "X$name" = "X$1" ] ; then
      value="$2"
      found=1
      shift
      # nobreak - last one wins
    fi
    shift
  done
  
  if [ $found -ne 0 ]; then
     echo "$value"
     return 0
  fi
  
  return 1
}

get_outdir()
{
  get_arg_by_name --distpath "$@" || echo "./dist"
}

get_workdir()
{
  get_arg_by_name --workpath "$@" || echo "./build"
}



if [ "$1" = "--bash" ]; then
    shift
    exec /bin/bash "$@"
    
elif [ -d "/src" ]; then
    cd /src/
    if [ -f /src/requirements.txt ]; then
        wine pip install -r /src/requirements.txt
    fi
    
    winew pyinstaller "$@"
    ret=$?
    
    # Change permissions of generated files to same as source dir's permissions
    owner=`stat -c "%u:%g" /src`
    chown -R "$owner" `get_outdir "$@"`
    chown -R "$owner" `get_workdir "$@"`
    
else
    echo "         _                _         _        _ _          "
    echo " __ __ _(_)_ _  _ __ _  _(_)_ _  __| |_ __ _| | |___ _ _  "
    echo " \ V  V / | ' \| '_ \ || | | ' \(_-<  _/ _' | | / -_) '_| "
    echo "  \_/\_/|_|_||_| .__/\_, |_|_||_/__/\__\__,_|_|_\___|_|   "
    echo "               |_|   |__/                                 "
    echo "Usage:"
    echo "A,"
    echo "To invoke pyinstaller, bind mount script directory as /src and pass pyinstaller parameters:"
    echo "docker run -it -v $(pwd):/src winpyinstaller [args] myscript.py"
    echo "docker run -it -v $(pwd):/src winpyinstaller [args] myscript.spec"
    echo "---"
    echo "B,"
    echo "To run bash pass --bash, and optionally bash parameters"
    echo "docker run -it winpyinstaller --bash"
    
fi



