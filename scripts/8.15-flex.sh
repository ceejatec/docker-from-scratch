#!/bin/bash -ex

cd /tmp
curl -LO https://github.com/westes/flex/releases/download/v${FLEX_VERSION}/flex-${FLEX_VERSION}.tar.gz
tar -xf flex-${FLEX_VERSION}.tar.gz
cd flex-${FLEX_VERSION}

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
make -j${PARALLELISM}
make install

ln -sv flex   /usr/bin/lex

cd /tmp
rm -rf flex-${FLEX_VERSION} flex-${FLEX_VERSION}.tar.gz
