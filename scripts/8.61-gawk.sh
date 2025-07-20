#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/gawk/gawk-${GAWK_VERSION}.tar.gz
tar -xf gawk-${GAWK_VERSION}.tar.gz
cd gawk-${GAWK_VERSION}

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf gawk-${GAWK_VERSION} gawk-${GAWK_VERSION}.tar.gz
