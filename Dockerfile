FROM debian:11 AS lfs-build

# The section headers here are from "Linux From Scratch, version 12.3"
# https://www.linuxfromscratch.org/lfs/view/12.3/

# 2.2.2 Host system requirements (plus additional requirements for building in Docker)
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        binutils \
        bison \
        coreutils \
        curl \
        diffutils \
        findutils \
        gawk \
        gcc \
        g++ \
        grep \
        gzip \
        m4 \
        make \
        patch \
        perl \
        python3 \
        sed \
        tar \
        texinfo \
        xz-utils \
        curl \
        ca-certificates \
    && apt clean all

RUN ln -sf /bin/bash /bin/sh

# Verify host system requirements
COPY scripts/2.2.2-host-requirements.sh /lfs-scripts/2.2.2-host-requirements.sh
RUN /lfs-scripts/2.2.2-host-requirements.sh | grep ERROR: ; \
    if [ $? -ne 0 ]; then \
        echo "Host system requirements are met." ; \
    else \
        echo "Host system requirements are NOT met." ; \
        exit 1 ; \
    fi

# 2.6 Create LFS installation directory
# Note: we store build stuff in /mnt/sources, outside the LFS tree -
# this is a change compared to the LFS book.
ENV LFS=/mnt/lfs
ENV LFS_SRC=/mnt/sources

# 4.2 Create limited directory layout in LFS filesystem.
COPY scripts/4.2-create-directory-layout.sh /lfs-scripts/4.2-create-directory-layout.sh
RUN /lfs-scripts/4.2-create-directory-layout.sh

# 4.3 Create the LFS user and group and set permissions
RUN set -x \
    && groupadd -g 1000 lfs \
    && useradd -s /bin/bash -g lfs -m -k /dev/null -u 1000 lfs \
    && chown -R lfs:lfs $LFS $LFS_SRC

# 4.4 Set up the environment for building LFS.
ARG TARGETARCH
ENV LC_ALL=POSIX
# QQQ!
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=${LFS}/pass1/bin:/bin:/usr/bin
ENV CONFIG_SITE=${LFS_SRC}/usr/share/config.site
RUN rm /etc/bash.bashrc

USER lfs

ARG PARALLELISM=8

#
# The goal here is to create a minimal working environment - with a
# glibc version of our choosing - that we can chroot into and build gcc
# from source. This requires quite some shenanigans.
#
# PASS 1 - build a cross toolchain in this Debian environment, with
# locally-built binutils and gcc. These are installed into the nascent
# LFS image under /pass1. It would be preferable to build them entirely
# outside the LFS filesystem, but the that eventually fails when trying
# to build libstdc++.
#

# 5.2 Binutils - pass 1

# NOTE: picking binutils != 2.44 will require tweaking the patch in the
# later script 6.17-binutils-pass2.sh.
ARG BINUTILS_VERSION=2.44
COPY scripts/5.2-binutils-pass1.sh /lfs-scripts/5.2-binutils-pass1.sh
RUN /lfs-scripts/5.2-binutils-pass1.sh

# 5.3 GCC - pass 1
ARG GLIBC_VERSION=2.28
ARG GCC_VERSION=13.2.0
ARG MPFR_VERSION=4.2.1
ARG GMP_VERSION=6.3.0
ARG MPC_VERSION=1.3.1
ARG GNU_MIRROR=https://mirrors.ocf.berkeley.edu/gnu
COPY scripts/5.3-gcc-pass1.sh /lfs-scripts/5.3-gcc-pass1.sh
RUN /lfs-scripts/5.3-gcc-pass1.sh

#
# Build minimal libraries into /usr on the LFS filesystem: the kernel
# headers, glibc (the whole reason we're doing this dance), libstdc++,
# ncurses, and zlib. These will be rebuilt and overwritten later.
#

# 5.4 Linux API Headers
ARG LINUX_VERSION=6.13.4
COPY scripts/5.4-linux-api-headers.sh /lfs-scripts/5.4-linux-api-headers.sh
RUN /lfs-scripts/5.4-linux-api-headers.sh

# 5.5 Glibc - this (and only this) is installed globally on the LFS filesystem.
ARG GLIBC_VERSION=2.28
COPY scripts/5.5-glibc-pass1.sh /lfs-scripts/5.5-glibc-pass1.sh
RUN /lfs-scripts/5.5-glibc-pass1.sh

# 5.6 Libstdc++
COPY scripts/5.6-libstdc++.sh /lfs-scripts/5.6-libstdc++.sh
RUN /lfs-scripts/5.6-libstdc++.sh

# 5.xx Zlib - required to run httpie later (not part of LFS)
ARG ZLIB_VERSION=1.3.1
COPY scripts/5.xx-zlib.sh /lfs-scripts/5.xx-zlib.sh
RUN /lfs-scripts/5.xx-zlib.sh

#
# PASS 2 - Using the cross toolchain we built in pass 1, build various
# tools into /pass2 in the LFS filesystem, culminating with the second
# build of gcc. These tools will be used to build the final LFS system
# in the chroot jail.
#

# We actually don't want these pass2 tools on the PATH yet, since they
# may not be compatible with the libraries in this Debian environment.

# 6.2 M4
ARG M4_VERSION=1.4.19
COPY scripts/6.2-m4.sh /lfs-scripts/6.2-m4.sh
RUN /lfs-scripts/6.2-m4.sh

# 6.3 Ncurses - required to build bash
ARG NCURSES_VERSION=6.5
COPY scripts/6.3-ncurses.sh /lfs-scripts/6.3-ncurses.sh
RUN /lfs-scripts/6.3-ncurses.sh

# 6.4 Bash - required to build GCC
# Use BASH_SHELL_VERSION since BASH_VERSION is a built-in variable in bash
ARG BASH_SHELL_VERSION=5.2.37
COPY scripts/6.4-bash.sh /lfs-scripts/6.4-bash.sh
RUN /lfs-scripts/6.4-bash.sh

# 6.5 Coreutils
ARG COREUTILS_VERSION=9.6
COPY scripts/6.5-coreutils.sh /lfs-scripts/6.5-coreutils.sh
RUN /lfs-scripts/6.5-coreutils.sh

# 6.6 Diffutils
ARG DIFFUTILS_VERSION=3.9
COPY scripts/6.6-diffutils.sh /lfs-scripts/6.6-diffutils.sh
RUN /lfs-scripts/6.6-diffutils.sh

# 6.7 File
ARG FILE_VERSION=5.46
COPY scripts/6.7-file.sh /lfs-scripts/6.7-file.sh
RUN /lfs-scripts/6.7-file.sh

# 6.8 Findutils
ARG FINDUTILS_VERSION=4.10.0
COPY scripts/6.8-findutils.sh /lfs-scripts/6.8-findutils.sh
RUN /lfs-scripts/6.8-findutils.sh

# 6.9 Gawk
ARG GAWK_VERSION=5.3.1
COPY scripts/6.9-gawk.sh /lfs-scripts/6.9-gawk.sh
RUN /lfs-scripts/6.9-gawk.sh

# 6.10 Grep
ARG GREP_VERSION=3.11
COPY scripts/6.10-grep.sh /lfs-scripts/6.10-grep.sh
RUN /lfs-scripts/6.10-grep.sh

# 6.11 Gzip
ARG GZIP_VERSION=1.13
COPY scripts/6.11-gzip.sh /lfs-scripts/6.11-gzip.sh
RUN /lfs-scripts/6.11-gzip.sh

# 6.12 Make
ARG MAKE_VERSION=4.4.1
COPY scripts/6.12-make.sh /lfs-scripts/6.12-make.sh
RUN /lfs-scripts/6.12-make.sh

# 6.13 Patch
ARG PATCH_VERSION=2.7.6
COPY scripts/6.13-patch.sh /lfs-scripts/6.13-patch.sh
RUN /lfs-scripts/6.13-patch.sh

# 6.14 Sed
ARG SED_VERSION=4.9
COPY scripts/6.14-sed.sh /lfs-scripts/6.14-sed.sh
RUN /lfs-scripts/6.14-sed.sh

# 6.15 Tar
ARG TAR_VERSION=1.35
COPY scripts/6.15-tar.sh /lfs-scripts/6.15-tar.sh
RUN /lfs-scripts/6.15-tar.sh

# 6.16 XZ
ARG XZ_VERSION=5.6.4
COPY scripts/6.16-xz.sh /lfs-scripts/6.16-xz.sh
RUN /lfs-scripts/6.16-xz.sh

# 6.17 Binutils - pass 2
COPY scripts/6.17-binutils-pass2.sh /lfs-scripts/6.17-binutils-pass2.sh
RUN /lfs-scripts/6.17-binutils-pass2.sh

# 6.18 GCC - pass 2
COPY scripts/6.18-gcc-pass2.sh /lfs-scripts/6.18-gcc-pass2.sh
RUN /lfs-scripts/6.18-gcc-pass2.sh

# 6.xx - Add httpie so the image has a way to download files without
# needing to install openssl (which requires installing perl....)
ARG HTTPIE_VERSION=3.4.0
ARG ZLIB_VERSION=1.3.1
COPY scripts/6.xx-httpie.sh /lfs-scripts/6.xx-httpie.sh
RUN /lfs-scripts/6.xx-httpie.sh

# 7.2 Clean up LFS - chown everything back to root, and delete /pass1.
# Also create /tmp.
USER root
RUN set -x \
    && mkdir -p ${LFS}/tmp \
    && chmod 1777 ${LFS}/tmp \
    && chown -R root:root ${LFS}
RUN ln -sf /pass2/bin/bash ${LFS}/bin/sh

FROM scratch AS lfs-chroot
COPY --from=lfs-build /mnt/lfs /

#
# PASS 3 - "chroot" by restarting the build from the current LFS image,
# and rebuild everything into /usr.
#

# Now we want the /pass2 tools on the PATH, but put them last so that
# we'll prefer to use the ones we're about to re-build.
ENV PATH=/bin:/usr/bin:/pass2/bin
ENV LFS_TGT=x86_64-lfs-linux-gnu
ARG PARALLELISM=8

# 8.5 glibc - pass 3
ARG GLIBC_VERSION=2.28
COPY scripts/8.5-glibc-pass3.sh /lfs-scripts/8.5-glibc-pass3.sh
RUN /lfs-scripts/8.5-glibc-pass3.sh

# 8.6 zlib
ARG ZLIB_VERSION=1.3.1
COPY scripts/8.6-zlib.sh /lfs-scripts/8.6-zlib.sh
RUN /lfs-scripts/8.6-zlib.sh

# 8.7 bzip2
ARG BZIP2_VERSION=1.0.8
COPY scripts/8.7-bzip2.sh /lfs-scripts/8.7-bzip2.sh
RUN /lfs-scripts/8.7-bzip2.sh

# 8.8 XZ
ARG XZ_VERSION=5.6.4
COPY scripts/8.8-xz.sh /lfs-scripts/8.8-xz.sh
RUN /lfs-scripts/8.8-xz.sh

# 8.9 LZ4
ARG LZ4_VERSION=1.10.4
COPY scripts/8.9-lz4.sh /lfs-scripts/8.9-lz4.sh
RUN /lfs-scripts/8.9-lz4.sh

# 8.10 zstd
ARG ZSTD_VERSION=1.5.7
COPY scripts/8.10-zstd.sh /lfs-scripts/8.10-zstd.sh
RUN /lfs-scripts/8.10-zstd.sh

# 8.11 File
ARG FILE_VERSION=5.46
COPY scripts/8.11-file.sh /lfs-scripts/8.11-file.sh
RUN /lfs-scripts/8.11-file.sh

# 8.12 readline
ARG READLINE_VERSION=8.2.13
COPY scripts/8.12-readline.sh /lfs-scripts/8.12-readline.sh
RUN /lfs-scripts/8.12-readline.sh

# 8.13 M4
ARG M4_VERSION=1.4.19
COPY scripts/8.13-m4.sh /lfs-scripts/8.13-m4.sh
RUN /lfs-scripts/8.13-m4.sh

# 8.15 flex
ARG FLEX_VERSION=2.6.4
COPY scripts/8.15-flex.sh /lfs-scripts/8.15-flex.sh
RUN /lfs-scripts/8.15-flex.sh

# 8.19 pkgconf
ARG PKGCONF_VERSION=2.3.0
COPY scripts/8.19-pkgconf.sh /lfs-scripts/8.19-pkgconf.sh
RUN /lfs-scripts/8.19-pkgconf.sh

# 8.29 GCC - pass 3
ARG GCC_VERSION=13.2.0
ARG MPFR_VERSION=4.2.1
ARG GMP_VERSION=6.3.0
ARG MPC_VERSION=1.3.1
ARG GNU_MIRROR=https://mirrors.ocf.berkeley.edu/gnu

# 8.30 Ncurses
ARG NCURSES_VERSION=6.5
COPY scripts/8.30-ncurses.sh /lfs-scripts/8.30-ncurses.sh
RUN /lfs-scripts/8.30-ncurses.sh


COPY scripts/8.29-gcc-pass3.sh /lfs-scripts/8.29-gcc-pass3.sh
RUN /lfs-scripts/8.29-gcc-pass3.sh

# # 8.42 Less
# ARG LESS_VERSION=668
# COPY scripts/8.42-less.sh /lfs-scripts/8.42-less.sh
# RUN /lfs-scripts/8.42-less.sh

# # 8.84 Strip LFS binaries, inside chroot jail
# COPY scripts/8.84-stripping.sh /lfs-scripts/8.84-stripping.sh
# RUN /lfs-scripts/8.84-stripping.sh

# RUN rm -rf /lfs-scripts

# FROM scratch AS lfs-final
# COPY --from=lfs-chroot / /
