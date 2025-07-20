#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/libtool/libtool-${LIBTOOL_VERSION}.tar.gz
tar -xf libtool-${LIBTOOL_VERSION}.tar.gz

cd libtool-${LIBTOOL_VERSION}

./configure --prefix=/usr
make -j${PARALLELISM}
make install

rm -fv /usr/lib/libltdl.a

cd /sources
rm -rf libtool-${LIBTOOL_VERSION} libtool-${LIBTOOL_VERSION}.tar.gz
