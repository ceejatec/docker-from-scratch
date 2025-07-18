#!/bin/bash -ex

cd /tmp

curl -LO ${GNU_MIRROR}/glibc/glibc-${GLIBC_VERSION}.tar.xz
tar -xf glibc-${GLIBC_VERSION}.tar.xz
cd glibc-${GLIBC_VERSION}
case $(uname -m) in
  x86_64)
    ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64 ;
    ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
  ;;
esac

mkdir build
cd build
echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=5.4                      \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib

make -j${PARALLELISM}
touch /etc/ld.so.conf

make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

# Create locales
localedef -i C -f UTF-8 C.UTF-8
localedef -i en_US -f UTF-8 en_US.UTF-8

# Create /etc/nsswitch.conf
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

# Add timezone data
tar -xf ../../tzdata2025a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO tz

ln -sfv /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

cd /tmp
rm -rf glibc-${GLIBC_VERSION} glibc-${GLIBC_VERSION}.tar.xz
