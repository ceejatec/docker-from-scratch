#!/bin/bash -ex

# Eliminate the /pass2 tools!
rm -rf /pass2 /sources /lfs-scripts

# Remove /pass2 from ld.so.conf
rm -f /etc/ld.so.conf.d/pass2.conf
ldconfig

# Eliminate unwanted docs and stuff
rm -rf /usr/share/{doc,info,man}
