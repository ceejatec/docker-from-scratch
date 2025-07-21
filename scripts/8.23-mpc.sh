#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/mpc/mpc-${MPC_VERSION}.tar.gz
tar -xf mpc-${MPC_VERSION}.tar.gz
cd mpc-${MPC_VERSION}

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-${MPC_VERSION}
make -j${PARALLELISM}
make install

cd /sources
rm -rf mpc-${MPC_VERSION} mpc-${MPC_VERSION}.tar.gz
