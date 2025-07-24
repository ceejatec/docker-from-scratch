#!/bin/bash -ex

cd /sources
download https://www.sudo.ws/dist/sudo-${SUDO_VERSION}.tar.gz
tar -xf sudo-${SUDO_VERSION}.tar.gz
cd sudo-${SUDO_VERSION}

./configure --prefix=/usr         \
            --libexecdir=/usr/lib \
            --with-secure-path    \
            --with-env-editor     \
            --docdir=/usr/share/doc/sudo-1.9.17p1 \
            --with-passprompt="[sudo] password for %p: "
make -j${PARALLELISM}
make install

cd /sources
rm -rf sudo-${SUDO_VERSION} sudo-${SUDO_VERSION}.tar.gz
