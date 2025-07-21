#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/libidn/libidn2-${LIBIDN2_VERSION}.tar.gz
tar -xf libidn2-${LIBIDN2_VERSION}.tar.gz
cd libidn2-${LIBIDN2_VERSION}

./configure --prefix=/usr --disable-static
make -j${PARALLELISM}
make install

cd /sources
rm -rf libidn2-${LIBIDN2_VERSION} libidn2-${LIBIDN2_VERSION}.tar.gz
