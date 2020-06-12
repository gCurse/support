#!/usr/bin/env bash

which brew
if [[ $? != 0 ]]
then
    echo -e 'Homebrew is not installed.\nSee https://brew.sh/ how to install homebrew.\nExiting.'
    exit 1
else
    echo 'This installation will be at best experimental. There is not much chance I can provide '
    echo 'in-depth help, but I might try :)'
    echo 'Please report problems at https://github.com/gCurse/support/issues'

    brew install python3 pygobject3 gtk+3 adwaita-icon-theme gstreamer \
                 gst-plugins-base gst-plugins-good gst-plugins-bad \
                 ffmpeg ffms2 mkvtoolnix mediainfo
    brew cask install mpv
    pip3 install appdirs psutil requests
    echo -e 'Now all necessary dependencies should have been installed.'
    echo -e 'Now run:'
    echo
    echo -e 'git clone --branch development --single-branch https://github.com/EinApfelBaum/otr-verwaltung3p.git'
    echo
    echo -e 'in the parent directory you would like to host otr-verwaltung3p.'
    echo -e 'Start the program with the full path (eg. ~/otr-verwaltung3p/bin/otrverwaltung3p)'
