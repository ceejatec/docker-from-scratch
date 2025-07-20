#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/mpfr/mpfr-${MPFR_VERSION}.tar.xz
tar -xf mpfr-${MPFR_VERSION}.tar.xz
cd mpfr-${MPFR_VERSION}

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-${MPFR_VERSION}
make -j${PARALLELISM}
make install

cd /sources
rm -rf mpfr-${MPFR_VERSION} mpfr-${MPFR_VERSION}.tar.xz
