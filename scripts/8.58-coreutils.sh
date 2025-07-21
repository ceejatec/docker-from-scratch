#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/coreutils/coreutils-${COREUTILS_VERSION}.tar.gz
download https://www.linuxfromscratch.org/patches/lfs/12.3/coreutils-9.6-i18n-1.patch
tar -xf coreutils-${COREUTILS_VERSION}.tar.gz

cd coreutils-${COREUTILS_VERSION}

patch -Np1 -i ../coreutils-9.6-i18n-1.patch

autoreconf -fv
automake -af
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
make -j${PARALLELISM}
make install
mv -v /usr/bin/chroot /usr/sbin

cd /sources
rm -rf coreutils-${COREUTILS_VERSION} coreutils-${COREUTILS_VERSION}.tar.gz
