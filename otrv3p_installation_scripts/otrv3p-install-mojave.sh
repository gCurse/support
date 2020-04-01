#!/usr/bin/env bash

which brew
if [[ $? != 0 ]]
then
    echo -e 'Homebrew is not installed. Exiting.'
    exit 1
else
    brew install python3 pygobject3 gtk+3 adwaita-icon-theme gstreamer \
                 gst-plugins-base gst-plugins-good gst-plugins-bad \
                 ffmpeg ffms2 mkvtoolnix mediainfo
    brew cask install mpv
    pip3 install pyxdg psutil requests
    echo -e 'Now all necessary dependencies should have been installed.'
    echo -e 'Now run:'
    echo -e 'git clone --branch development --single-branch https://github.com/EinApfelBaum/otr-verwaltung3p.git'
    echo -e 'in the parent directory you would like to host otr-verwaltung3p'
