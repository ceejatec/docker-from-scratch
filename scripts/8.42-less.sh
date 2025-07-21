#!/bin/bash -ex

cd /sources
https --download https://www.greenwoodsoftware.com/less/less-${LESS_VERSION}.tar.gz -o less-${LESS_VERSION}.tar.gz
tar -xf less-${LESS_VERSION}.tar.gz
cd less-${LESS_VERSION}
./configure --prefix=/usr --sysconfdir=/etc
make -j${PARALLELISM}
make install

cd /sources
rm -rf less-${LESS_VERSION} less-${LESS_VERSION}.tar.gz