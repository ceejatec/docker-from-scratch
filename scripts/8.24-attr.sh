#!/pass2/bin/bash -ex

cd /sources
download https://download.savannah.gnu.org/releases/attr/attr-${ATTR_VERSION}.tar.gz
tar -xf attr-${ATTR_VERSION}.tar.gz
cd attr-${ATTR_VERSION}

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-${ATTR_VERSION}
make -j${PARALLELISM}
make install

cd /sources
rm -rf attr-${ATTR_VERSION} attr-${ATTR_VERSION}.tar.gz
