#!/bin/bash -ex

# We already have uv in /root from the 7.xx-download.sh script.
# Use it to install meson.
uv tool install meson==${MESON_VERSION}
