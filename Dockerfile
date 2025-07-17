FROM debian:11

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
ENV LFS=/mnt/lfs
ENV LFS_SRC=/mnt/sources

# 4.2 Create limited directory layout in LFS filesystem.
# Note: we store build stuff in /mnt/sources, outside the LFS tree -
# this is a change compared to the LFS book.
COPY scripts/4.2-create-directory-layout.sh /lfs-scripts/4.2-create-directory-layout.sh
RUN /lfs-scripts/4.2-create-directory-layout.sh

# 4.3 Create the LFS user and group and set permissions
RUN set -x \
    && groupadd -g 1000 lfs \
    && useradd -s /bin/bash -g lfs -m -k /dev/null -u 1000 lfs \
    && chown -R lfs:lfs $LFS $LFS_SRC

# 4.4 Set up the LFS environment
ARG TARGETARCH
ENV LC_ALL=POSIX
# QQQ!
ENV LFS_TGT=x86_64-lfs-linux-gnu
ENV PATH=/bin:/usr/bin:${LFS}/tools/bin
ENV CONFIG_SITE=${LFS_SRC}/usr/share/config.site
RUN rm /etc/bash.bashrc

USER lfs

ARG PARALLELISM=8

# 5.2 Binutils - pass 1

# NOTE: upgrading binutils will require tweaking the patch in the later
# script 6.17-binutils-pass2.sh.
ARG BINUTILS_VERSION=2.44
COPY scripts/5.2-binutils-pass1.sh /lfs-scripts/5.2-binutils-pass1.sh
RUN /lfs-scripts/5.2-binutils-pass1.sh

# 5.3 GCC - pass 1
ARG GLIBC_VERSION=2.28
ARG GCC_VERSION=14.2.0
ARG MPFR_VERSION=4.2.1
ARG GMP_VERSION=6.3.0
ARG MPC_VERSION=1.3.1
ARG GNU_MIRROR=https://mirrors.ocf.berkeley.edu/gnu
COPY scripts/5.3-gcc-pass1.sh /lfs-scripts/5.3-gcc-pass1.sh
RUN /lfs-scripts/5.3-gcc-pass1.sh

# 5.4 Linux API Headers
ARG LINUX_VERSION=6.13.4
COPY scripts/5.4-linux-api-headers.sh /lfs-scripts/5.4-linux-api-headers.sh
RUN /lfs-scripts/5.4-linux-api-headers.sh

# # 5.5 Glibc
ARG GLIBC_VERSION=2.28
COPY scripts/5.5-glibc.sh /lfs-scripts/5.5-glibc.sh
RUN /lfs-scripts/5.5-glibc.sh

# 5.6 Libstdc++
COPY scripts/5.6-libstdc++.sh /lfs-scripts/5.6-libstdc++.sh
RUN /lfs-scripts/5.6-libstdc++.sh

# 6.2 M4
ARG M4_VERSION=1.4.19
COPY scripts/6.2-m4.sh /lfs-scripts/6.2-m4.sh
RUN /lfs-scripts/6.2-m4.sh

# 6.3 Ncurses
ARG NCURSES_VERSION=6.5
COPY scripts/6.3-ncurses.sh /lfs-scripts/6.3-ncurses.sh
RUN /lfs-scripts/6.3-ncurses.sh

# 6.4 Bash
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
