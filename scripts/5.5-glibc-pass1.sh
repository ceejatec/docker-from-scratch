#!/bin/bash -ex

cd $LFS_SRC
curl -LO ${GNU_MIRROR}/glibc/glibc-${GLIBC_VERSION}.tar.xz
tar -xf glibc-${GLIBC_VERSION}.tar.xz
cd glibc-${GLIBC_VERSION}
case $(uname -m) in
  x86_64)
    ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64 ;
    ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
  ;;
esac

mkdir build
cd build
echo "rootsbindir=/usr/sbin" > configparms

../configure                         \
  --disable-werror                   \
  --prefix=/usr                      \
  --host=$LFS_TGT                    \
  --build=$(../scripts/config.guess) \
  --enable-kernel=5.4                \
  --with-headers=$LFS/usr/include    \
  --disable-nscd                     \
  libc_cv_slibdir=/usr/lib

make -j${PARALLELISM}
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

cd $LFS_SRC
rm -rf glibc-${GLIBC_VERSION} glibc-${GLIBC_VERSION}.tar.xz

# Basic test
cd /tmp
echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux
rm a.out
