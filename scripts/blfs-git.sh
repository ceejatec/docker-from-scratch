#!/bin/bash -ex

cd /sources
download https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.xz
tar -xf git-${GIT_VERSION}.tar.xz
cd git-${GIT_VERSION}

./configure --prefix=/usr \
            --with-gitconfig=/etc/gitconfig
make -j${PARALLELISM}
make install

cd /sources
rm -rf git-${GIT_VERSION} git-${GIT_VERSION}.tar.xz
