#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/diffutils/diffutils-${DIFFUTILS_VERSION}.tar.xz
tar -xf diffutils-${DIFFUTILS_VERSION}.tar.xz
cd diffutils-${DIFFUTILS_VERSION}
./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf diffutils-${DIFFUTILS_VERSION} diffutils-${DIFFUTILS_VERSION}.tar.xz
