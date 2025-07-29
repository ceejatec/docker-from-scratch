#!/bin/bash -ex

cd /tmp
# Note: we need --enable-gold on aarch64, because Golang still requires
# gold. For consistency, we build it regardless of platform.
# --enable-ld=default ensures that ld.bfd is used unless gold is
# specifically requested. This may need to be revisited as gold is
# deprecated starting in binutils 2.44 (hence the separate
# "binutils-with-gold" tarball).
# https://github.com/golang/go/issues/22040
download ${GNU_MIRROR}/binutils/binutils-with-gold-${BINUTILS_VERSION}.tar.xz
tar -xf binutils-with-gold-${BINUTILS_VERSION}.tar.xz
cd binutils-with-gold-${BINUTILS_VERSION}

mkdir build
cd build
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-gold       \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

make -j${PARALLELISM} tooldir=/usr
make tooldir=/usr install

rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/

cd /tmp
rm -rf binutils-${BINUTILS_VERSION} binutils-${BINUTILS_VERSION}.tar.xz
