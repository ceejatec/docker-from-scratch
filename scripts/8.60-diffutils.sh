#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/diffutils/diffutils-${DIFFUTILS_VERSION}.tar.gz
tar -xf diffutils-${DIFFUTILS_VERSION}.tar.gz
cd diffutils-${DIFFUTILS_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf diffutils-${DIFFUTILS_VERSION} diffutils-${DIFFUTILS_VERSION}.tar.gz
