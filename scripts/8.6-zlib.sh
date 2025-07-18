#!/bin/bash -ex

cd /tmp
curl -LO https://zlib.net/zlib-${ZLIB_VERSION}.tar.xz
tar -xf zlib-${ZLIB_VERSION}.tar.xz
cd zlib-${ZLIB_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

rm -fv /usr/lib/libz.a

cd /tmp
rm -rf zlib-${ZLIB_VERSION} zlib-${ZLIB_VERSION}.tar.xz
