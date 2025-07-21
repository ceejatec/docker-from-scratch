#!/bin/bash -ex

cd /sources
env
download https://astron.com/pub/file/file-${FILE_VERSION}.tar.gz
tar -xf file-${FILE_VERSION}.tar.gz
cd file-${FILE_VERSION}

# Build and install
./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf file-${FILE_VERSION} file-${FILE_VERSION}.tar.gz
