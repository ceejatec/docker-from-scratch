#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/grep/grep-${GREP_VERSION}.tar.xz
tar -xf grep-${GREP_VERSION}.tar.xz
cd grep-${GREP_VERSION}

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf grep-${GREP_VERSION} grep-${GREP_VERSION}.tar.xz
