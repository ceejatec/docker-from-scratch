#!/bin/bash -ex

cd /sources
download https://github.com/rockdaboot/libpsl/releases/download/${LIBPSL_VERSION}/libpsl-${LIBPSL_VERSION}.tar.gz
tar -xf libpsl-${LIBPSL_VERSION}.tar.gz
cd libpsl-${LIBPSL_VERSION}

mkdir build
cd build

# Reminder that meson is installed temporarily in /root/.local/bin and
# won't be in the final image
export PATH=${PATH}:${HOME}/.local/bin
meson setup --prefix=/usr --buildtype=release
ninja
ninja install

cd /sources
rm -rf *
