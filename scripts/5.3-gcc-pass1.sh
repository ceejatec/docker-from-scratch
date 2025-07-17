#!/bin/bash -ex

# Download all source
cd $LFS_SRC
curl -LO ${GNU_MIRROR}/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz
tar -xf gcc-${GCC_VERSION}.tar.xz
cd gcc-${GCC_VERSION}
curl -LO ${GNU_MIRROR}/gmp/gmp-${GMP_VERSION}.tar.xz
tar -xf gmp-${GMP_VERSION}.tar.xz
mv gmp-${GMP_VERSION} gmp
curl -LO ${GNU_MIRROR}/mpfr/mpfr-${MPFR_VERSION}.tar.xz
tar -xf mpfr-${MPFR_VERSION}.tar.xz
mv mpfr-${MPFR_VERSION} mpfr
curl -LO ${GNU_MIRROR}/mpc/mpc-${MPC_VERSION}.tar.gz
tar -xf mpc-${MPC_VERSION}.tar.gz
mv mpc-${MPC_VERSION} mpc

# Set default directory names to 'lib'
case $(uname -m) in
     x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
        ;;
esac

mkdir build
cd build
../configure                \
  --target=$LFS_TGT         \
  --prefix=$LFS/tools   \
  --with-glibc-version=${GLIBC_VERSION} \
  --with-sysroot=$LFS       \
  --with-newlib             \
  --without-headers         \
  --enable-default-pie      \
  --enable-default-ssp      \
  --disable-nls             \
  --disable-shared          \
  --disable-multilib        \
  --disable-threads         \
  --disable-libatomic       \
  --disable-libgomp         \
  --disable-libquadmath     \
  --disable-libssp          \
  --disable-libvtv          \
  --disable-libstdcxx       \
  --enable-languages=c,c++
make -j${PARALLELISM}
make install

# Fix limits.h
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > $(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h

cd $LFS_SRC
rm -rf gcc-${GCC_VERSION} gcc-${GCC_VERSION}.tar.xz
