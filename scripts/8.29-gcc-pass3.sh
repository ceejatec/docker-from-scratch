#!/pass2/bin/bash -ex

# Download all source
cd /tmp
http --download GET ${GNU_MIRROR}/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz -o gcc-${GCC_VERSION}.tar.xz
tar -xf gcc-${GCC_VERSION}.tar.xz
cd gcc-${GCC_VERSION}
http --download GET ${GNU_MIRROR}/gmp/gmp-${GMP_VERSION}.tar.xz -o gmp-${GMP_VERSION}.tar.xz
tar -xf gmp-${GMP_VERSION}.tar.xz
mv gmp-${GMP_VERSION} gmp
http --download GET ${GNU_MIRROR}/mpfr/mpfr-${MPFR_VERSION}.tar.xz -o mpfr-${MPFR_VERSION}.tar.xz
tar -xf mpfr-${MPFR_VERSION}.tar.xz
mv mpfr-${MPFR_VERSION} mpfr
http --download GET ${GNU_MIRROR}/mpc/mpc-${MPC_VERSION}.tar.gz -o mpc-${MPC_VERSION}.tar.gz
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
../configure --prefix=/opt/gcc-${GCC_VERSION} \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

make -j${PARALLELISM}
make install

ln -sv gcc /opt/gcc-${GCC_VERSION}/bin/cc

cd /tmp
rm -rf gcc-${GCC_VERSION} gcc-${GCC_VERSION}.tar.xz
