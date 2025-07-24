#!/bin/bash -ex

# Get rid of UV/meson; httpie; all the build scripts; and
# anything in /tmp.
rm -rf /root/.local /root/.cache \
    /httpie \
    /lfs-scripts /sources \
    /tmp/*

# Eliminate unwanted docs and stuff
rm -rf \
    /usr/share/{doc,info,man} \
    /usr/man \
    /opt/gcc-*/share/{info,locale,man}

# Remove unwanted localization files
find /usr/share/locale -mindepth 1 -maxdepth 1 -name en\* -prune -o -print | xargs rm -rf
