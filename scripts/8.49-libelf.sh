#!/pass2/bin/bash -ex

cd /sources
download https://sourceware.org/ftp/elfutils/${LIBELF_VERSION}/elfutils-${LIBELF_VERSION}.tar.bz2
tar -xf elfutils-${LIBELF_VERSION}.tar.bz2
cd elfutils-${LIBELF_VERSION}

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

make -j${PARALLELISM}
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd /sources
rm -rf elfutils-${LIBELF_VERSION} elfutils-${LIBELF_VERSION}.tar.bz2
