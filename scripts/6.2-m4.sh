#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/m4/m4-${M4_VERSION}.tar.xz
tar -xf m4-${M4_VERSION}.tar.xz
cd m4-${M4_VERSION}
./configure --prefix=/pass2 \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf m4-${M4_VERSION} m4-${M4_VERSION}.tar.xz
