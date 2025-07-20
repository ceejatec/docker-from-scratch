#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/make/make-${PASS2_MAKE_VERSION}.tar.gz
tar -xf make-${PASS2_MAKE_VERSION}.tar.gz
cd make-${PASS2_MAKE_VERSION}

./configure --prefix=/pass2 \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf make-${PASS2_MAKE_VERSION} make-${PASS2_MAKE_VERSION}.tar.gz
