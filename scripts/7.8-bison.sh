#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/bison/bison-${BISON_VERSION}.tar.xz
tar -xf bison-${BISON_VERSION}.tar.xz
cd bison-${BISON_VERSION}

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2
make -j${PARALLELISM}
make install

cd /sources
rm -rf bison-${BISON_VERSION} bison-${BISON_VERSION}.tar.xz
