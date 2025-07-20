#!/pass2/bin/bash -ex

cd /sources
download https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-${PROCPS_VERSION}.tar.xz
tar -xf procps-ng-${PROCPS_VERSION}.tar.xz
cd procps-ng-${PROCPS_VERSION}

./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.5 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit
make -j${PARALLELISM}
make install

cd /sources
rm -rf procps-ng-${PROCPS_VERSION} procps-ng-${PROCPS_VERSION}.tar.xz
