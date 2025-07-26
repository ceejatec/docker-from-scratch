#!/bin/bash -ex

cd /sources

# Download and install the basics of make-ca
download https://github.com/lfs-book/make-ca/archive/v${MAKE_CA_VERSION}/make-ca-${MAKE_CA_VERSION}.tar.gz
tar -xf make-ca-${MAKE_CA_VERSION}.tar.gz
cd make-ca-${MAKE_CA_VERSION}

find / | grep -v '^/proc' | sort > /tmp/before.txt
mkdir -pv /
make DESTDIR= make_ca install_bin install_cs install_mozilla_ca_root
install -vdm755 /etc/ssl/local
find / | grep -v '^/proc' | sort > /tmp/after.txt

# Proceeed to build and install p11-kit
cd /sources
download https://github.com/p11-glue/p11-kit/releases/download/${P11_KIT_VERSION}/p11-kit-${P11_KIT_VERSION}.tar.xz
tar -xf p11-kit-${P11_KIT_VERSION}.tar.xz
cd p11-kit-${P11_KIT_VERSION}

# This edit may need to be changed in different p11-kit versions.
sed '20,$ d' -i trust/trust-extract-compat

cat >> trust/trust-extract-compat << "EOF"
# Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

# Update trust stores
/usr/sbin/make-ca -r
EOF

mkdir p11-build &&
cd    p11-build &&

# Reminder that meson is installed temporarily in /root/.local/bin and
# won't be in the final image
export PATH=${PATH}:/root/.local/bin

meson setup ..            \
      --prefix=/usr  \
      --buildtype=release \
      -D trust_paths=/etc/pki/anchors &&
ninja
ninja install

# "make-ca -g" expects for everything to installed in /usr, so we can't
# run that. Extract the certdata.txt URL from make-ca, and then run it
# without the -g option.
eval $(grep 'URL=' /usr/sbin/make-ca)
download ${URL}
/usr/sbin/make-ca -g

find / | grep -v '^/proc' | sort > /tmp/after-p11.txt

cd /sources
rm -rf p11-kit-${P11_KIT_VERSION} p11-kit-${P11_KIT_VERSION}.tar.xz
