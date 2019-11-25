FROM ubuntu:16.04
MAINTAINER Scott Belden <scottabelden@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y python3-software-properties software-properties-common apt-transport-https && \
    apt-add-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ xenial main' && \
    dpkg --add-architecture i386 && \
    apt-get update -y && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get install -y --allow-unauthenticated wget unzip winehq-stable && \
    apt-get clean

ARG WINEPREFIX=/wine
ENV WINEPREFIX=${WINEPREFIX:-/wine}

WORKDIR ${WINEPREFIX}/drive_c
# Disable all fixme: sdebug from wine
ENV WINEDEBUG=-all
ENV WINEPATH='c:\swigwin;c:\upx'

COPY winew.sh /usr/local/bin/winew
COPY wineapploader.sh /usr/local/bin/wineapploader
RUN chmod +x /usr/local/bin/winew /usr/local/bin/wineapploader && \
    ln -s wineapploader /usr/local/bin/python && \
    ln -s wineapploader /usr/local/bin/pip && \
    ln -s wineapploader /usr/local/bin/pyinstaller


COPY *.msi *.zip *.exe *.txt ./
ADD setup.sh /usr/local/bin/winpyinstaller_setup.sh
ADD msvc9compiler.py msvc9compiler.py
RUN chmod +x /usr/local/bin/winpyinstaller_setup.sh && \
    /usr/local/bin/winpyinstaller_setup.sh

# entrypoint
COPY entrypoint.sh /usr/local/bin/winpyinstaller
RUN chmod +x /usr/local/bin/winpyinstaller
ENTRYPOINT [ "winpyinstaller" ]

# Extra python packages
ARG EXTRA_PACKAGES=''
ENV EXTRA_PACKAGES=${EXTRA_PACKAGES:-''}

 # Install extra packages from command line
RUN if [ -n "$EXTRA_PACKAGES" ]; then \
      echo "Installing extra packages: $EXTRA_PACKAGES..."; \
      winew pip install --upgrade $EXTRA_PACKAGES; \
    fi


WORKDIR /src
