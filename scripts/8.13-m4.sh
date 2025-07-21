#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/m4/m4-${M4_VERSION}.tar.xz
tar -xf m4-${M4_VERSION}.tar.xz
cd m4-${M4_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf m4-${M4_VERSION} m4-${M4_VERSION}.tar.xz
