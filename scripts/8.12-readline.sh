#!/bin/bash -ex

cd /tmp
curl -LO ${GNU_MIRROR}/readline/readline-${READLINE_VERSION}.tar.gz
tar -xf readline-${READLINE_VERSION}.tar.gz
cd readline-${READLINE_VERSION}

# Prevent hard-coding rpath
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

# Build and install
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2.13
make -j${PARALLELISM} SHLIB_LIBS="-lncursesw"
make install

cd /tmp
rm -rf readline-${READLINE_VERSION} readline-${READLINE_VERSION}.tar.gz
