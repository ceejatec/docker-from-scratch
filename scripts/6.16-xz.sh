#!/bin/bash -ex

cd $LFS_SRC
curl -LO https://github.com/tukaani-project/xz/releases/download/v${XZ_VERSION}/xz-${XZ_VERSION}.tar.xz
tar -xf xz-${XZ_VERSION}.tar.xz
cd xz-${XZ_VERSION}
./configure --prefix=/pass2                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/pass2/share/doc/xz-${XZ_VERSION}
make -j${PARALLELISM}
make DESTDIR=$LFS install

rm -v $LFS/pass2/lib/liblzma.la

cd $LFS_SRC
rm -rf xz-${XZ_VERSION} xz-${XZ_VERSION}.tar.xz
