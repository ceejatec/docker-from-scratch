#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/automake/automake-${AUTOMAKE_VERSION}.tar.gz
tar -xf automake-${AUTOMAKE_VERSION}.tar.gz

cd automake-${AUTOMAKE_VERSION}

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.17
make -j${PARALLELISM}
make install

cd /sources
rm -rf automake-${AUTOMAKE_VERSION} automake-${AUTOMAKE_VERSION}.tar.gz
