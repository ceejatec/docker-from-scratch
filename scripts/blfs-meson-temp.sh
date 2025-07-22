#!/bin/bash -ex

cd /sources

UV=uv-$(uname -m)-unknown-linux-gnu
download https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${UV}.tar.gz
tar -xf ${UV}.tar.gz

mkdir -pv ${HOME}/.local/bin
export PATH=${PATH}:${HOME}/.local/bin
cp -a $UV/uv ${HOME}/.local/bin

uv tool install meson==${MESON_VERSION}

cd /sources
rm -rf *
