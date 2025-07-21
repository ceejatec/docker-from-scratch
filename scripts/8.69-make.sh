#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/make/make-${MAKE_VERSION}.tar.gz
tar -xf make-${MAKE_VERSION}.tar.gz
cd make-${MAKE_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf make-${MAKE_VERSION} make-${MAKE_VERSION}.tar.gz
