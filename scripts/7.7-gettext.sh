#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/gettext/gettext-${GETTEXT_VERSION}.tar.xz
tar -xf gettext-${GETTEXT_VERSION}.tar.xz
cd gettext-${GETTEXT_VERSION}

./configure --disable-shared
make -j${PARALLELISM}
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd /sources
rm -rf gettext-${GETTEXT_VERSION} gettext-${GETTEXT_VERSION}.tar.xz
