#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/gzip/gzip-${GZIP_VERSION}.tar.xz
tar -xf gzip-${GZIP_VERSION}.tar.xz
cd gzip-${GZIP_VERSION}

./configure --prefix=/pass2 --host=$LFS_TGT
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf gzip-${GZIP_VERSION} gzip-${GZIP_VERSION}.tar.xz
