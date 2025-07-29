#!/bin/bash -ex

cd $LFS_SRC

# Copy uv from the previous stage - we'll need it again in BLFS, so
# stick it in /root along with httpie
cp -a /pass2/bin/uv /root/.local/bin

# Make this helper shell script
cat << 'EOF' > /root/.local/bin/download
#!/bin/bash -ex
LD_LIBRARY_PATH=/pass2/lib uv run \
    /root/.local/bin/download_file.py "$1" $(basename "$1")
EOF
chmod 755 /root/.local/bin/download
