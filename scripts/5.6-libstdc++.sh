#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz
tar -xf gcc-${GCC_VERSION}.tar.xz
cd gcc-${GCC_VERSION}

mkdir build
cd build
../libstdc++-v3/configure         \
  --host=$LFS_TGT                 \
  --build=$(../config.guess)      \
  --prefix=/usr                   \
  --disable-multilib              \
  --disable-nls                   \
  --disable-libstdcxx-pch         \
  --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/${GCC_VERSION}
make -j${PARALLELISM}
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

cd $LFS_SRC
rm -rf gcc-${GCC_VERSION} gcc-${GCC_VERSION}.tar.xz
