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

# Allow building libgcc and libstdc++ with POSIX threads
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir build
cd build
../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
    --prefix=/pass2                                \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libsanitizer                         \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++
make -j${PARALLELISM}
make DESTDIR=$LFS install

ln -sv gcc $LFS/pass2/bin/cc

cd $LFS_SRC
rm -rf gcc-${GCC_VERSION} gcc-${GCC_VERSION}.tar.xz
