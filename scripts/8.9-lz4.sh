#!/bin/bash -ex

cd /tmp
curl -LO https://github.com/lz4/lz4/releases/download/v${LZ4_VERSION}/lz4-${LZ4_VERSION}.tar.gz
tar -xf lz4-${LZ4_VERSION}.tar.gz
cd lz4-${LZ4_VERSION}

make -j${PARALLELISM} BUILD_STATIC=no PREFIX=/usr
make BUILD_STATIC=no PREFIX=/usr install

cd /tmp
rm -rf lz4-${LZ4_VERSION} lz4-${LZ4_VERSION}.tar.gz
