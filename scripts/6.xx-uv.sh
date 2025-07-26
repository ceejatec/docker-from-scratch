#!/bin/bash -ex

cd $LFS_SRC

# Download and install uv - download the "musl" version which is static,
# so we don't have to worry about the limited libraries in the chroot
# jail.
UV=uv-$(uname -m)-unknown-linux-gnu
curl -LO https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${UV}.tar.gz
tar -xf ${UV}.tar.gz

cp -a $UV/uv $LFS/pass2/bin

rm -rf $LFS_SRC/*
