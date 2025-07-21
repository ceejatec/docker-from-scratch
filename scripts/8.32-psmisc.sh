#!/bin/bash -ex

cd /sources
download https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-${PSMISC_VERSION}.tar.xz
tar -xf psmisc-${PSMISC_VERSION}.tar.xz

cd psmisc-${PSMISC_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf psmisc-${PSMISC_VERSION} psmisc-${PSMISC_VERSION}.tar.xz
