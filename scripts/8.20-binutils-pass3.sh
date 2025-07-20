#!/pass2/bin/bash -ex

cd /tmp
download https://sourceware.org/pub/binutils/releases/binutils-${BINUTILS_VERSION}.tar.xz
tar -xf binutils-${BINUTILS_VERSION}.tar.xz
cd binutils-${BINUTILS_VERSION}

mkdir build
cd build
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
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
