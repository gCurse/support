#!/usr/bin/env bash

# otrv3p-install-deb-development.sh
version="0.1.3"
# 2021-05-05
# https://raw.githubusercontent.com/einapfelbaum/otr-verwaltung3p/master/installscripts/otrv3p-install-deb.sh

# BEGIN LICENSE
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>
# END LICENSE

# Made by gcurse.github.io


# colors
RED='\033[1;31m'
BLUE='\033[1;34m'
NOC='\033[0m'  # no color

check_root () {
    ## Check if we are root
    if [ "$(id -u)" != "0" ]; then
        root=0
    else
        root=1
    fi
}

create_desktop_file () {
    echo "otrv3p:create_desktop_file: Erzeuge otrv3p-git.desktop in $HOME/.local/share/applications" | tee -a /tmp/otrv3p-install.log
    echo "[Desktop Entry]
Type=Application
Name=OTR-Verwaltung3p-git
GenericName=Verwaltung von OTR-Dateien
GenericName[en]=Management of OTR-Files
Comment=Dateien von onlinetvrecorder.com verwalten: Schneiden, Schnitte betrachten, Cutlists bewerten...
Comment[en]=Manage files from onlinetvrecorder.com : decode, cut, review cuts, rate cutlists...
Categories=AudioVideo;AudioVideoEditing;
Exec=$HOME/otr-verwaltung3p/bin/otrverwaltung3p
Terminal=0
Icon=$HOME/otr-verwaltung3p/data/media/icon.png

" > $HOME/.local/share/applications/otrv3p-git.desktop
}

install_deps () {
    check_root
    if [ $root = 1 ]; then
        if [ ! -e /tmp/otrv3p-install.log ]; then touch /tmp/otrv3p-install.log; fi
        chown root /tmp/otrv3p-install.log && chmod 666 /tmp/otrv3p-install.log
        echo "otrv3p:install_deps: Installiere Abhängigkeiten" | tee -a /tmp/otrv3p-install.log
        for package in  ffmpeg                          \
                        ffmsindex                       \
                        gir1.2-gstreamer-1.0            \
                        gir1.2-gtk-3.0                  \
                        gstreamer1.0-gtk3               \
                        gstreamer1.0-libav              \
                        gstreamer1.0-plugins-bad        \
                        gstreamer1.0-plugins-base       \
                        gstreamer1.0-plugins-base-apps  \
                        gstreamer1.0-plugins-good       \
                        gstreamer1.0-plugins-ugly       \
                        gstreamer1.0-tools              \
                        gstreamer1.0-x                  \
                        mediainfo                       \
                        mediainfo-gui                   \
                        mkvtoolnix                      \
                        mpv                             \
                        python3-appdirs                 \
                        python3-cairo                   \
                        python3-gi-cairo                \
                        python3-gst-1.0                 \
                        python3-requests                \
                        python3-xdg                     \
                        git                             \
                        x264; do
            ## Only install packages if they are not already installed
            ## dkpg -s <packagename> returns 0 if package is installed else 1
            dpkg -s "$package" > /dev/null 2>&1 || apt-get -qq -y install "$package" 2>&1 | grep -ve "Preparing to unpack.*" | tee -a /tmp/otrv3p-install.log
        done
        if [ $? = 0 ]; then echo -e "Alle Abhängigkeiten sind (jetzt) installiert.\n"; fi
        exit
    else
        echo -e "\n\n${RED}otrv3p:install_deps: Diese Skriptfunktion muss als root ausgeführt werden${NOC}\n\n" | tee -a /tmp/otrv3p-install.log
        exit
    fi
}

install_otrv3p_git () {
    check_root
    if [ $root = 0 ]; then
        cd $HOME
        if [[ -d "otr-verwaltung3p" ]]; then
            echo -e "otrv3p:install_otrv3p_git: Das Verzeichnis $HOME/otr-verwaltung3p existiert. Das Repo wird nicht geklont." | tee -a /tmp/otrv3p-install.log
            cd otr-verwaltung3p
            git checkout --track origin/development 2>&1 | tee -a /tmp/otrv3p-install.log
            git pull
            echo -e "otrv3p:install_otrv3p_git: Bestehendes Repo wurde auf den development-Branch umgestellt." | tee -a /tmp/otrv3p-install.log
            cd ..
            echo "no" > /tmp/otrv3pCloneYesNo
        else
            git clone --branch development --single-branch --shallow-since=2020-02-14 \
                      https://github.com/EinApfelBaum/otr-verwaltung3p.git 2>&1 | tee -a /tmp/otrv3p-install.log
            echo "yes" > /tmp/otrv3pCloneYesNo
        fi
        mkdir -p $HOME/.local/share/applications 2>&1 | tee -a /tmp/otrv3p-install.log
        mkdir -p $HOME/.local/share/otrverwaltung 2>&1 | tee -a /tmp/otrv3p-install.log
        create_desktop_file
        echo "otrv3p:install_otrv3p_git: Updating desktop database" | tee -a /tmp/otrv3p-install.log
        update-desktop-database $HOME/.local/share/applications 2>&1 | tee -a /tmp/otrv3p-install.log
        exit
    else
        echo -e "\n\n${RED}install_otrv3p_git: Diese Skriptfunktion darf nicht als root ausgeführt werden${NOC}\n\n" | tee -a /tmp/otrv3p-install.log
        exit
    fi
}

usage () {
    echo -e "\n${BLUE}"
    echo -e "Die Installation wird in zwei Schritten durchgeführt werden:\n"
    echo -e "    1. Installation der Abhängigkeiten (Root-Rechte benötigt)."
    echo -e "    2. Installation der otr-verwaltung3p (ohne Root-Rechte)."
    echo -e "Das läuft automatisch ab. Bereit? Dann weiter mit der Eingabetaste, abbrechen mit Strg-C${NOC}"
    read dummy
}

if [ -z "$1" ]; then
    check_root
    if [ $root = 1 ]; then
        echo -e "\n\n${RED}Dieses Skript darf nicht als root ausgeführt werden${NOC}\n\n" | tee -a /tmp/otrv3p-install.log
        exit 1
    fi

    #export myhome=$HOME
    echo -e "\n"$(date +"%Y-%m-%d_%H:%M:%S")" LOG BEGINS\n" >> /tmp/otrv3p-install.log
    usage
elif [ "$1" = "deps" ]; then
    #myhome="$2"
    install_deps
elif [ "$1" = "prog" ]; then
    #myhome="$2"
    install_otrv3p_git
else
    echo -e "\n\n${RED}otrv3p: Das hätte niemals passieren dürfen! THE END${NOC}\n\n" 2>&1 | tee -a /tmp/otrv3p-install.log
    exit 1
fi

# Recursive call
echo "otrv3p: Start sudo $0 deps $myhome" | tee -a /tmp/otrv3p-install.log
sudo "$0" deps #$myhome
# Recursive call
echo "otrv3p: Start $0 prog $myhome" | tee -a /tmp/otrv3p-install.log
"$0" prog #$myhome
clone=$(cat /tmp/otrv3pCloneYesNo)
rm /tmp/otrv3pCloneYesNo
echo -e '\n\nPlease report any issues at https://github.com/EinApfelBaum/otr-verwaltung3p/issues'
