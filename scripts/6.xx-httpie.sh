#!/bin/bash -ex

# httpie depends on zlib
cd $LFS_SRC
curl -LO https://zlib.net/zlib-${ZLIB_VERSION}.tar.xz
tar -xf zlib-${ZLIB_VERSION}.tar.xz
cd zlib-${ZLIB_VERSION}
./configure --prefix=/usr
make -j${PARALLELISM}
make DESTDIR=$LFS install

cd $LFS_SRC
rm -rf zlib-${ZLIB_VERSION} zlib-${ZLIB_VERSION}.tar.xz

# Download and install httpie
curl -L packages.httpie.io/binaries/linux/http-latest -o $LFS/usr/bin/http
chmod 755 $LFS/usr/bin/http
ln -s http $LFS/usr/bin/https
