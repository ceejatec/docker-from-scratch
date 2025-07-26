#!/bin/bash -ex

export LFS_TGT=$(uname -m)-lfs-linux-gnu

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/gawk/gawk-${GAWK_VERSION}.tar.xz
tar -xf gawk-${GAWK_VERSION}.tar.xz
cd gawk-${GAWK_VERSION}

sed -i 's/extras//' Makefile.in

./configure --prefix=/pass2 \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf gawk-${GAWK_VERSION} gawk-${GAWK_VERSION}.tar.xz
