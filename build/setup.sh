#!/bin/sh

do_clean=1

# Do cleaning?
echo "$@" | grep -q '\<--no-clean\>' >/dev/null && do_clean=0
  


WINEDEBUG=-all
WINEPATH='c:\swigwin;c:\upx'
export WINEDEBUG WINEPATH

WINEPREFIX=${WINEPREFIX:-$HOME/.wine}
export WINEPREFIX

set -e

python_url="https://www.python.org/ftp/python/2.7.17/python-2.7.17.msi"
pywin32_url="https://github.com/mhammond/pywin32/releases/download/b227/pywin32-227.win32-py2.7.exe"
vcpython27_url="http://download.microsoft.com/download/7/9/6/796EF2E4-801B-4FC4-AB28-B59FBF6D907B/VCForPython27.msi"
swigwin_url="https://sourceforge.net/projects/swig/files/swigwin/swigwin-4.0.1/swigwin-4.0.1.zip/download"
upx_url="https://github.com/upx/upx/releases/download/v3.95/upx-3.95-win32.zip"



python=python.msi
pywin32=pywin32.exe
vcpython27=`basename "$vcpython27_url"`
swigwin=swigwin.zip
upx=upx-win32.zip

drive_c="$WINEPREFIX/drive_c"
python27_dir="$drive_c/Python27"


download_if_missing()
{
  if [ "$#" -gt 1 ]; then
    outfile="$2"
  else
    outfile=`basename "$1"`
  fi
  
  if [ -f "$outfile" ]; then
    echo "$outfile already exist, skipping download" 1>&2
    return 0
  fi
  
  wget "$1" -O "$outfile"
}

echo "Running in `pwd`" 1>&2

# Preload Wine for faster subsequend access
echo "Preloading wine..." 1>&2
wine cmd /c 'echo OK, PATH: %PATH%' 1>&2

# Install Swig
download_if_missing "$swigwin_url" "$swigwin"
echo "Unzipping Swig..." 1>&2
unzip -o "$swigwin" >/dev/null
rm -f swigwin
ln -s swigwin-*/ swigwin

# Check if swig works
echo -n "Testing if Swig works..." 1>&2
wine swig -help >/dev/null
echo "OK" 1>&2

# Install upx_url
download_if_missing "$upx_url" "$upx"
echo "Unzippping UPX..." 1>&2
unzip -o "$upx" >/dev/null
rm -f upx
ln -s upx-*/ upx
# Check if upx works
echo -n "Testing if UPX works..." 1>&2
wine upx --version > /tmp/upx_version
head -n 1 /tmp/upx_version 1>&2
rm /tmp/upx_version

# Install windows python
download_if_missing "$python_url" "$python"
echo "Installing Python: msiexec -i $python /qn..." 1>&2
wine msiexec -i "$python" /qn

# copy pywin32 libs to the correct location
download_if_missing "$pywin32_url" "$pywin32"
echo "Unzipping PyWin32..." 1>&2
unzip -o "$pywin32" >/dev/null || true
echo "Installing PyWin32..." 1>&2
cp -R PLATLIB/* "$python27_dir/Lib/site-packages"
cp SCRIPTS/pywin32_postinstall.py "$python27_dir"
wine "$python27_dir/python.exe" "$python27_dir/pywin32_postinstall.py" -install
rm -rf PLATLIB SCRIPTS || true


# install windows c compiler for python
cp msvc9compiler.py "$python27_dir/Lib/distutils/msvc9compiler.py"

download_if_missing "$vcpython27_url" "$vcpython27"
echo "Installing VCPython27: msiexec -i $vcpython27 /qn..." 1>&2
wine msiexec -i "$vcpython27" /qn


# Upgrade PIP
echo "Upgrading PIP..." 1>&2
wine "$python27_dir/python.exe" -m pip install --upgrade pip

# install pyinstaller
echo "Installing PyInstaller..." 1>&2
wine "$python27_dir/python.exe" -m pip install pyinstaller


# Install extra packages
if [ -f extra_packages.txt ]; then
  echo "Installing extra packages from extra_packages.txt..." 1>&2
  wine "$python27_dir/python.exe" -m pip install -r extra_packages.txt
fi

# Install extra packages from command line
if [ -n "$EXTRA_PACKAGES" ]; then
  echo "Installing extra packages: $EXTRA_PACKAGES..."
  wine "$python27_dir/python.exe" -m pip install --upgrade $EXTRA_PACKAGES
fi

if [ "$do_clean" -ne 0 ]; then
  # Remove all installation packages
  echo "Removing unneeded installation packages..."
  rm -f "$python" "$pywin32" "$vcpython27" "$swigwin" "$upx" "msvc9compiler.py"
  
  echo "Removing unneeded PIP cache and MSI temporaries..."
  # Remove cached PIP packages
  rm -rf "users/$USER/Local Settings/Application Data/pip/"*
  # Remove unneeded installer packages (over 100MB)
  rm -rf windows/Installer/*
fi

echo "Wine Python setup done" 1>&2
