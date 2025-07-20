#!/pass2/bin/bash -ex

cd /sources
download https://www.kernel.org/pub/linux/utils/util-linux/v${UTIL_LINUX_VERSION%.*}/util-linux-${UTIL_LINUX_VERSION}.tar.xz
tar -xf util-linux-${UTIL_LINUX_VERSION}.tar.xz
cd util-linux-${UTIL_LINUX_VERSION}

./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            --without-systemd     \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-${UTIL_LINUX_VERSION}
make -j${PARALLELISM}
make install

cd /sources
rm -rf tar-${TAR_VERSION} tar-${TAR_VERSION}.tar.gz
