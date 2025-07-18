#!/bin/bash -ex

cd /tmp
curl -LO https://github.com/facebook/zstd/releases/download/v${ZSTD_VERSION}/zstd-${ZSTD_VERSION}.tar.gz
tar -xf zstd-${ZSTD_VERSION}.tar.gz
cd zstd-${ZSTD_VERSION}

make -j${PARALLELISM} prefix=/usr
make prefix=/usr install

rm -v /usr/lib/libzstd.a

cd /tmp
rm -rf zstd-${ZSTD_VERSION} zstd-${ZSTD_VERSION}.tar.gz
