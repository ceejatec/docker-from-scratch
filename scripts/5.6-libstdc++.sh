#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/gcc/gcc-${INITIAL_GCC_VERSION}/gcc-${INITIAL_GCC_VERSION}.tar.xz
tar -xf gcc-${INITIAL_GCC_VERSION}.tar.xz
cd gcc-${INITIAL_GCC_VERSION}

mkdir build
cd build
../libstdc++-v3/configure         \
  --host=$LFS_TGT                 \
  --build=$(../config.guess)      \
  --prefix=/usr                   \
  --disable-multilib              \
  --disable-nls                   \
  --disable-libstdcxx-pch         \
  --with-gxx-include-dir=/pass1/$LFS_TGT/include/c++/${INITIAL_GCC_VERSION}
make -j${PARALLELISM}
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++,supc++}*.la

cd $LFS_SRC
rm -rf gcc-${INITIAL_GCC_VERSION} gcc-${INITIAL_GCC_VERSION}.tar.xz
