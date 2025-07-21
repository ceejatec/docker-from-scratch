#!/bin/bash -ex

cd /sources
case $(uname -m) in
    x86_64) NINJA_PKG=ninja-linux.zip ;;
    aarch64) NINJA_PKG=ninja-linux-aarch64.zip ;;
    *) echo "Unsupported architecture: $(uname -m)" && exit 1 ;;
esac

download https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/${NINJA_PKG}
7z x ${NINJA_PKG}
mv ninja /usr/bin/

ninja --version

cd /sources
rm -rf ninja*
