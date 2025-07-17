#!/bin/bash -ex

# Source will have been downloaded for us in the Dockerfile
cd /tmp
tar -xf openssl.tar.gz
cd openssl-*
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic no-ssl2 no-ssl3

make -j${PARALLELISM}
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

cd /tmp
rm -rf openssl-* openssl.tar.gz
