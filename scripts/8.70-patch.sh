#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/patch/patch-${PATCH_VERSION}.tar.gz
tar -xf patch-${PATCH_VERSION}.tar.gz
cd patch-${PATCH_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf patch-${PATCH_VERSION} patch-${PATCH_VERSION}.tar.gz
