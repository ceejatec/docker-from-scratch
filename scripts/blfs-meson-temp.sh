#!/bin/bash -ex

# We already have uv in /root from the 6.xx-httpie.sh script.
# Use it to install meson.
uv tool install meson==${MESON_VERSION}
