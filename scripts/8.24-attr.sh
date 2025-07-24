#!/bin/bash -ex

cd /sources
# For whatever reason, this download site is flaky. Try a few times.
for n in {1..5}; do
  download https://download.savannah.gnu.org/releases/attr/attr-${ATTR_VERSION}.tar.gz && break || sleep 5
done
if [ ! -f attr-${ATTR_VERSION}.tar.gz ]; then
  echo "Failed to download attr-${ATTR_VERSION}.tar.gz after 5 attempts."
  exit 1
fi

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
