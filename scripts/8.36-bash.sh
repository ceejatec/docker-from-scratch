#!/pass2/bin/bash -ex

cd /sources
download ${GNU_MIRROR}/bash/bash-${BASH_SHELL_VERSION}.tar.gz
tar -xf bash-${BASH_SHELL_VERSION}.tar.gz
cd bash-${BASH_SHELL_VERSION}

./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-${BASH_SHELL_VERSION}

make -j${PARALLELISM}
make install

ln -svf bash /bin/sh

cd /sources
rm -rf bash-${BASH_SHELL_VERSION} bash-${BASH_SHELL_VERSION}.tar.gz
