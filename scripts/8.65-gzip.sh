#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/gzip/gzip-${GZIP_VERSION}.tar.gz
tar -xf gzip-${GZIP_VERSION}.tar.gz
cd gzip-${GZIP_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf gzip-${GZIP_VERSION} gzip-${GZIP_VERSION}.tar.gz
