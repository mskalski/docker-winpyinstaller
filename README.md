docker-winpyinstaller
=====================

This is intended to use docker to create a windows executable of a python
script. Therefore, you can develop a script on a non Windows environment,
package it up into an executable, and then move that executable to a
Windows environment where it can be run.


Heavily adopted from [scottbelden/docker-winpyinstaller](https://github.com/scottbelden/docker-winpyinstaller),
some ideas also come from [kicsikrumpli/wine-pyinstaller](https://github.com/kicsikrumpli/wine-pyinstaller).

I needed only Python-2.7 32-bit, so it supports only this configuration.  
If you need Python3, linux and/or 64-bit support, see https://github.com/cdrx/docker-pyinstaller.


## Building the image

To build the image, simply do the following:

```sh
./build/build.sh [extra build args]
```

This will install wine, Windows python, pywin32, pyinstaller, swig, upx, as well as the
Windows compiler for Python so that scripts requiring compiled dependencies can
be built.

Extra build args are passed unmodified to `docker build` command. 
You can use `--build-arg EXTRA_PACKAGES='<packages>'` or drop into `build` directory
`extra_packages.txt` file (compatible with PIP's `requirements.txt` file) to add extra python
packages to resulting image.

Tried to make building possible offline, so all required installation packages may be dropped here
(as `python.msi`, `upx-win32.zip`, `pywin32.exe`, `swigwin.zip`, `VCForPython27.msi`)
to `./build` directory, but still need internet connection for installing pyinstaller
and extra dependencies.

## Building the Windows executable

To build the executable, simply do the following:

```sh
./winpyinstaller [-C chdir-to] [-I docker-image] [--] [pyinstaller params and options]
```

If your script has dependencies, they should be defined in a requirements.txt
in the source folder.

Script `winpyinstaller` may be copied to some location somewhere in $PATH - should work.
