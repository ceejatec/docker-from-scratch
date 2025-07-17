#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/coreutils/coreutils-${COREUTILS_VERSION}.tar.xz
tar -xf coreutils-${COREUTILS_VERSION}.tar.xz
cd coreutils-${COREUTILS_VERSION}
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
make -j${PARALLELISM}
make DESTDIR=$LFS install

# Fix up some program locations
mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

cd $LFS_SRC
rm -rf coreutils-${COREUTILS_VERSION} coreutils-${COREUTILS_VERSION}.tar.xz
