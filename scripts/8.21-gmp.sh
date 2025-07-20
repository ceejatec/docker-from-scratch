#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/gmp/gmp-${GMP_VERSION}.tar.xz
tar -xf gmp-${GMP_VERSION}.tar.xz
cd gmp-${GMP_VERSION}

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-${GMP_VERSION}
make -j${PARALLELISM}
make install

cd /sources
rm -rf gmp-${GMP_VERSION} gmp-${GMP_VERSION}.tar.xz
