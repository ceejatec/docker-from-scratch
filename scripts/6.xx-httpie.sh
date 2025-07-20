#!/bin/bash -ex

# Download and install httpie
curl -L packages.httpie.io/binaries/linux/http-latest -o $LFS/pass2/bin/http
chmod 755 $LFS/pass2/bin/http
ln -s http $LFS/pass2/bin/https

# httpie seems to work weirdly from bash in a `docker build`
# environment, so make this helper shell script:
cat << 'EOF' > $LFS/pass2/bin/download
#!/pass2/bin/bash -ex
/pass2/bin/http --download GET "$1" -o $(basename "$1")
EOF
chmod 755 $LFS/pass2/bin/download
