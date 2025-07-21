#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/libtasn1/libtasn1-${LIBTASN1_VERSION}.tar.gz
tar -xf libtasn1-${LIBTASN1_VERSION}.tar.gz
cd libtasn1-${LIBTASN1_VERSION}

./configure --prefix=/usr --disable-static
make -j${PARALLELISM}
make install

cd /sources
rm -rf libtasn1-${LIBTASN1_VERSION} libtasn1-${LIBTASN1_VERSION}.tar.gz
