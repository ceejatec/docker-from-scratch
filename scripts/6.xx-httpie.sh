#!/bin/bash -ex

# Download and install httpie
mkdir -pv $LFS/httpie/bin
curl -L packages.httpie.io/binaries/linux/http-latest -o $LFS/httpie/bin/http
chmod 755 $LFS/httpie/bin/http
ln -s http $LFS/httpie/bin/https

# httpie seems to work weirdly from bash in a `docker build`
# environment, so make this helper shell script:
cat << 'EOF' > $LFS/httpie/bin/download
#!/bin/bash -ex
/httpie/bin/http --download GET "$1" -o $(basename "$1")
EOF
chmod 755 $LFS/httpie/bin/download
