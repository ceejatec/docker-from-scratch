#!/bin/bash -ex

cd /sources
download https://github.com/rockdaboot/libpsl/releases/download/${LIBPSL_VERSION}/libpsl-${LIBPSL_VERSION}.tar.gz
tar -xf libpsl-${LIBPSL_VERSION}.tar.gz
cd libpsl-${LIBPSL_VERSION}

# So, we don't want to install all of python and meson just to build
# this. So, turn to our good friend uv. Not installing it into the image
# at this time, so it's OK to hard-code a version here.
UV=uv-$(uname -m)-unknown-linux-gnu
download https://github.com/astral-sh/uv/releases/download/0.8.0/${UV}.tar.gz
tar -xf ${UV}.tar.gz
export PATH=${PATH}:${PWD}/${UV}

# This will dump stuff into /root
find / > /tmp/pre-uv.txt
uv tool install meson
find / > /tmp/post-uv.txt

# Now, actually build libpsl
mkdir build
cd build
meson setup --prefix=/usr --buildtype=release
ninja
ninja install

cd /sources
rm -rf *
