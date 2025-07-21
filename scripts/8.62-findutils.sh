#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/findutils/findutils-${FINDUTILS_VERSION}.tar.xz
tar -xf findutils-${FINDUTILS_VERSION}.tar.xz
cd findutils-${FINDUTILS_VERSION}

./configure --prefix=/usr --localstatedir=/var/lib/locate
make -j${PARALLELISM}
make install

cd /sources
rm -rf findutils-${FINDUTILS_VERSION} findutils-${FINDUTILS_VERSION}.tar.xz
