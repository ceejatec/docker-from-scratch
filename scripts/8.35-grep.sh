#!/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/grep/grep-${GREP_VERSION}.tar.gz
tar -xf grep-${GREP_VERSION}.tar.gz

cd grep-${GREP_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

cd /sources
rm -rf grep-${GREP_VERSION} grep-${GREP_VERSION}.tar.gz
