#!/bin/bash -ex

cd $LFS_SRC
curl -LO https://www.kernel.org/pub/linux/kernel/v${LINUX_VERSION%%.*}.x/linux-${LINUX_VERSION}.tar.xz
tar -xf linux-${LINUX_VERSION}.tar.xz
cd linux-${LINUX_VERSION}
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
cd $LFS_SRC
rm -rf linux-${LINUX_VERSION} linux-${LINUX_VERSION}.tar.xz
