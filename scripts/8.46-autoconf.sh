#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/autoconf/autoconf-${AUTOCONF_VERSION}.tar.gz
tar -xf autoconf-${AUTOCONF_VERSION}.tar.gz

cd autoconf-${AUTOCONF_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf autoconf-${AUTOCONF_VERSION} autoconf-${AUTOCONF_VERSION}.tar.gz
