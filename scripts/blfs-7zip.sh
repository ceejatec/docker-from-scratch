#!/bin/bash -ex

cd /sources
case $(uname -m) in
    x86_64) SEVENZIP_ARCH=x64 ;;
    aarch64) SEVENZIP_ARCH=arm64 ;;
    *) echo "Unsupported architecture: $(uname -m)" && exit 1 ;;
esac

download https://github.com/ip7z/7zip/releases/download/${SEVENZIP_VERSION}/7z${SEVENZIP_VERSION//./}-linux-${SEVENZIP_ARCH}.tar.xz
tar -xf 7z${SEVENZIP_VERSION//./}-linux-${SEVENZIP_ARCH}.tar.xz

# Install it as "7z" since that's what everyone expects
mv 7zz /usr/bin/7z

7z --help

cd /sources
rm -rf *
