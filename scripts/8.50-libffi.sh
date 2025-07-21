#!/bin/bash -ex

cd /sources
download https://github.com/libffi/libffi/releases/download/v${LIBFFI_VERSION}/libffi-${LIBFFI_VERSION}.tar.gz
tar -xf libffi-${LIBFFI_VERSION}.tar.gz
cd libffi-${LIBFFI_VERSION}

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native

make -j${PARALLELISM}
make install

cd /sources
rm -rf libffi-${LIBFFI_VERSION} libffi-${LIBFFI_VERSION}.tar.gz
