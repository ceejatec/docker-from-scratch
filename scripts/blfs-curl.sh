#!/bin/bash -ex

cd /sources
download https://curl.se/download/curl-${CURL_VERSION}.tar.xz
tar -xf curl-${CURL_VERSION}.tar.xz
cd curl-${CURL_VERSION}

./configure --prefix=/usr    \
            --disable-static \
            --with-openssl   \
            --with-ca-path=/etc/ssl/certs \
            --disable-docs

make -j${PARALLELISM}

# Install stripped binaries - can't strip them after the fact because
# one file is hard-linked many dozens of times
make install-strip

cd /sources
rm -rf curl-${CURL_VERSION} curl-${CURL_VERSION}.tar.xz
