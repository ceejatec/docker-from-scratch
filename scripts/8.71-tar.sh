#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/tar/tar-${TAR_VERSION}.tar.gz
tar -xf tar-${TAR_VERSION}.tar.gz
cd tar-${TAR_VERSION}

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf tar-${TAR_VERSION} tar-${TAR_VERSION}.tar.gz
