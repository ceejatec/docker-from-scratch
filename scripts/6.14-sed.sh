#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/sed/sed-${SED_VERSION}.tar.xz
tar -xf sed-${SED_VERSION}.tar.xz
cd sed-${SED_VERSION}
./configure --prefix=/pass2   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf sed-${SED_VERSION} sed-${SED_VERSION}.tar.xz
