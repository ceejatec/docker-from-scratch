#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/sed/sed-${SED_VERSION}.tar.gz
tar -xf sed-${SED_VERSION}.tar.gz

cd sed-${SED_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf sed-${SED_VERSION} sed-${SED_VERSION}.tar.gz
