#!/bin/bash -ex

# Eliminate the /pass2 tools!
rm -rf /pass2 /sources /lfs-scripts

# Eliminate unwanted docs and stuff
rm -rf /usr/share/{doc,info,man}

# Copy libgcc_s to /lib64, for running downloaded binaries
cp /opt/gcc-${GCC_VERSION}/lib/libgcc_s.so.1 /lib64/

# Remove /pass2 from ld.so.conf
echo "/usr/lib" > /etc/ld.so.conf
echo "/lib64" >> /etc/ld.so.conf
ldconfig
