#!/bin/bash -ex

# Download and install httpie
curl -L packages.httpie.io/binaries/linux/http-latest -o $LFS/pass2/bin/http
chmod 755 $LFS/pass2/bin/http
ln -s http $LFS/pass2/bin/https
