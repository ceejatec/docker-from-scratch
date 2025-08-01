#!/bin/bash -ex

export LFS_TGT=$(uname -m)-lfs-linux-gnu

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/tar/tar-${TAR_VERSION}.tar.xz
tar -xf tar-${TAR_VERSION}.tar.xz
cd tar-${TAR_VERSION}
./configure --prefix=/pass2                   \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf tar-${TAR_VERSION} tar-${TAR_VERSION}.tar.xz
