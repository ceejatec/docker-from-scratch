#!/bin/bash -ex

cd $LFS_SRC

# uv installs things into HOME
export HOME=/root

# Install httpie using uv
LD_LIBRARY_PATH=/pass2/lib uv tool install httpie==${HTTPIE_VERSION}

# httpie seems to work weirdly from bash in a `docker build`
# environment, so make this helper shell script:
cat << 'EOF' > /root/.local/bin/download
#!/bin/bash -ex
http --download GET "$1" -o $(basename "$1")
EOF
chmod 755 /root/.local/bin/download

# Copy uv from the previous stage - we'll need it again in BLFS, so
# stick it in /root along with httpie
cp -a /pass2/bin/uv /root/.local/bin
