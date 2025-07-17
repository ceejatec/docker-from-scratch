#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/make/make-${MAKE_VERSION}.tar.gz
tar -xf make-${MAKE_VERSION}.tar.gz
cd make-${MAKE_VERSION}

./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf make-${MAKE_VERSION} make-${MAKE_VERSION}.tar.gz
