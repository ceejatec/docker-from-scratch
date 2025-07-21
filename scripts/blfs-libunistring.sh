#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/libunistring/libunistring-${LIBUNISTRING_VERSION}.tar.xz
tar -xf libunistring-${LIBUNISTRING_VERSION}.tar.xz
cd libunistring-${LIBUNISTRING_VERSION}

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libunistring-${LIBUNISTRING_VERSION}
make -j${PARALLELISM}
make install

cd /sources
rm -rf libunistring-${LIBUNISTRING_VERSION} libunistring-${LIBUNISTRING_VERSION}.tar.xz
