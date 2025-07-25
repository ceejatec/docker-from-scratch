#!/bin/bash -ex

export LFS_TGT=$(uname -m)-lfs-linux-gnu

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/patch/patch-${PATCH_VERSION}.tar.gz
tar -xf patch-${PATCH_VERSION}.tar.gz
cd patch-${PATCH_VERSION}

./configure --prefix=/pass2 \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf patch-${PATCH_VERSION} patch-${PATCH_VERSION}.tar.gz
