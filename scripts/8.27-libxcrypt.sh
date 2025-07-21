#!/bin/bash -ex

cd /sources
download https://github.com/besser82/libxcrypt/releases/download/v${LIBXCRYPT_VERSION}/libxcrypt-${LIBXCRYPT_VERSION}.tar.xz
tar -xf libxcrypt-${LIBXCRYPT_VERSION}.tar.xz
cd libxcrypt-${LIBXCRYPT_VERSION}

./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
make -j${PARALLELISM}
make install

cd /sources
rm -rf libxcrypt-${LIBXCRYPT_VERSION} libxcrypt-${LIBXCRYPT_VERSION}.tar.xz
