#!/bin/bash -ex

cd $LFS_SRC
curl -LO https://astron.com/pub/file/file-${FILE_VERSION}.tar.gz
tar -xf file-${FILE_VERSION}.tar.gz
cd file-${FILE_VERSION}

# Make a local copy of the "file" command
mkdir build
pushd build
../configure --disable-bzlib      \
             --disable-libseccomp \
             --disable-xzlib      \
             --disable-zlib
make -j${PARALLELISM}
popd

# Build and install the real package
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make -j${PARALLELISM} FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install

# Clean an unwanted file
rm -v $LFS/usr/lib/libmagic.la

cd $LFS_SRC
rm -rf file-${FILE_VERSION} file-${FILE_VERSION}.tar.gz
