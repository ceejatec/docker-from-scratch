#!/bin/bash -ex

export LFS_TGT=$(uname -m)-lfs-linux-gnu

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/coreutils/coreutils-${COREUTILS_VERSION}.tar.xz
tar -xf coreutils-${COREUTILS_VERSION}.tar.xz
cd coreutils-${COREUTILS_VERSION}
./configure --prefix=/pass2                   \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf coreutils-${COREUTILS_VERSION} coreutils-${COREUTILS_VERSION}.tar.xz
