#!/bin/bash -ex

export LFS_TGT=$(uname -m)-lfs-linux-gnu

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/findutils/findutils-${FINDUTILS_VERSION}.tar.xz
tar -xf findutils-${FINDUTILS_VERSION}.tar.xz
cd findutils-${FINDUTILS_VERSION}
./configure --prefix=/pass2                 \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf findutils-${FINDUTILS_VERSION} findutils-${FINDUTILS_VERSION}.tar.xz
