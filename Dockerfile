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
# Note that we don't necessarily build the same gcc here as we want in
# the final image. We need to build a gcc that we are sure will build
# our final glibc correctly. In particular, glibc 2.28 has a bug that
# causes scanf() and friends to fail when it is built with gcc 13.2.0,
# leading to nasty subtle bugs in at least the "file" command and with
# GCC LTO. So, we build an earlier version of gcc first, specified by
# the build arg INITIAL_GCC_VERSION, which will be used to build
# everything up until the final (pass 3) gcc build.
#

# 5.2 Binutils - pass 1

# NOTE: picking binutils != 2.44 will require tweaking the patch in the
# later script 6.17-binutils-pass2.sh.
ARG BINUTILS_VERSION=2.44
COPY scripts/5.2-binutils-pass1.sh /lfs-scripts/5.2-binutils-pass1.sh
RUN /lfs-scripts/5.2-binutils-pass1.sh

# 5.3 GCC - pass 1
ARG GLIBC_VERSION=2.28
ARG INITIAL_GCC_VERSION=10.2.0
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

# 5.6 Libstdc++ also built from INITIAL_GCC_VERSION
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

# 6.12 Make - note that earlier versions of glibc send make 4.4+ into an
# infinite loop, so for this pass build make 4.3. We'll build a newer
# one in pass 3.
# https://github.com/crosstool-ng/crosstool-ng/issues/1932#issuecomment-1528139734
ARG PASS2_MAKE_VERSION=4.3
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

# 6.18 GCC - pass 2 (still building INITIAL_GCC_VERSION)
COPY scripts/6.18-gcc-pass2.sh /lfs-scripts/6.18-gcc-pass2.sh
RUN /lfs-scripts/6.18-gcc-pass2.sh

# 6.xx - Add httpie so the image has a way to download files without
# needing to install openssl (which requires installing perl....). Put
# this into /httpie because it will still be used when we get to BLFS
# packages.
ARG HTTPIE_VERSION=3.4.0
COPY scripts/6.xx-httpie.sh /lfs-scripts/6.xx-httpie.sh
RUN /lfs-scripts/6.xx-httpie.sh

# 7.2 Clean up LFS - chown everything back to root, and delete /pass1.
# Also create /tmp.
USER root
RUN set -x \
    && mkdir -p ${LFS}/tmp \
    && chmod 1777 ${LFS}/tmp \
    && rm -rf ${LFS}/pass1 \
    && chown -R root:root ${LFS}

FROM scratch AS lfs-chroot

#
# PASS 3 - "chroot" by restarting the build from the current LFS image,
# and rebuild everything into /usr.
#

COPY --from=lfs-build /mnt/lfs /

# Now we want the /pass2 tools on the PATH, but put them last so that
# we'll prefer to use the ones we're about to re-build into /usr. We
# also want /httpie which only has the `download` script. Also add
# /usr/sbin since several of these tools install there.
ENV PATH=/bin:/usr/bin:/usr/sbin:/pass2/bin:/httpie/bin
ENV LFS_TGT=x86_64-lfs-linux-gnu
ARG PARALLELISM=8
ARG GNU_MIRROR=https://mirrors.ocf.berkeley.edu/gnu

RUN mkdir /sources

# 7.6 Create essential files
COPY scripts/7.6-essential-files.sh /lfs-scripts/7.6-essential-files.sh
RUN /lfs-scripts/7.6-essential-files.sh

# 7.7 gettext
ARG GETTEXT_VERSION=0.24
COPY scripts/7.7-gettext.sh /lfs-scripts/7.7-gettext.sh
RUN /lfs-scripts/7.7-gettext.sh

# 7.8 Bison
ARG BISON_VERSION=3.8.2
COPY scripts/7.8-bison.sh /lfs-scripts/7.8-bison.sh
RUN /lfs-scripts/7.8-bison.sh

# 7.9 Perl
ARG PERL_VERSION=5.40.1
COPY scripts/7.9-perl.sh /lfs-scripts/7.9-perl.sh
RUN /lfs-scripts/7.9-perl.sh

# 8.5.1 install glibc - pass 3
ARG GLIBC_VERSION=2.28
ARG TZDATA_VERSION=2025a
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
ARG LZ4_VERSION=1.10.0
COPY scripts/8.9-lz4.sh /lfs-scripts/8.9-lz4.sh
RUN /lfs-scripts/8.9-lz4.sh

# 8.10 zstd
ARG ZSTD_VERSION=1.5.7
COPY scripts/8.10-zstd.sh /lfs-scripts/8.10-zstd.sh
RUN /lfs-scripts/8.10-zstd.sh

# 8.11 File
# Note: versions of file >= 5.38 use `sscanf()` to parse GUIDs, and this
# fails with glibc 2.28 in this image. I spent hours tracking that down,
# and more hours trying to find a workaround, but it seems like the
# easiest thing is just to use an earlier version of file.
ARG FILE_VERSION=5.38
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

# 8.20 Binutils - pass 3
ARG BINUTILS_VERSION=2.44
COPY scripts/8.20-binutils-pass3.sh /lfs-scripts/8.20-binutils-pass3.sh
RUN /lfs-scripts/8.20-binutils-pass3.sh

# 8.24 Attributes
ARG ATTR_VERSION=2.5.2
COPY scripts/8.24-attr.sh /lfs-scripts/8.24-attr.sh
RUN /lfs-scripts/8.24-attr.sh

# 8.27 libxcrypt
ARG LIBXCRYPT_VERSION=4.4.38
COPY scripts/8.27-libxcrypt.sh /lfs-scripts/8.27-libxcrypt.sh
RUN /lfs-scripts/8.27-libxcrypt.sh

# 8.28 shadow
ARG SHADOW_VERSION=4.17.3
COPY scripts/8.28-shadow.sh /lfs-scripts/8.28-shadow.sh
RUN /lfs-scripts/8.28-shadow.sh

# 8.29 GCC - pass 3
# Note: LFS builds GMP, MPRF, and MPC separately, installing them into
# /usr. Since we're installing gcc into /opt and may want to have
# several versions of gcc installed, we integrate the build for those
# libraries into the gcc build script.
ARG GMP_VERSION=6.2.1
ARG MPFR_VERSION=4.1.0
ARG MPC_VERSION=1.2.1
ARG GCC_VERSION=13.2.0
COPY scripts/8.29-gcc-pass3.sh /lfs-scripts/8.29-gcc-pass3.sh
RUN /lfs-scripts/8.29-gcc-pass3.sh

# 8.30 Ncurses
ARG NCURSES_VERSION=6.5
COPY scripts/8.30-ncurses.sh /lfs-scripts/8.30-ncurses.sh
RUN /lfs-scripts/8.30-ncurses.sh

# 8.31 sed
ARG SED_VERSION=4.9
COPY scripts/8.31-sed.sh /lfs-scripts/8.31-sed.sh
RUN /lfs-scripts/8.31-sed.sh

# 8.32 psmisc
ARG PSMISC_VERSION=23.7
COPY scripts/8.32-psmisc.sh /lfs-scripts/8.32-psmisc.sh
RUN /lfs-scripts/8.32-psmisc.sh

# 8.35 grep
ARG GREP_VERSION=3.11
COPY scripts/8.35-grep.sh /lfs-scripts/8.35-grep.sh
RUN /lfs-scripts/8.35-grep.sh

# 8.36 Bash
# Use BASH_SHELL_VERSION since BASH_VERSION is a built-in variable in bash
ARG BASH_SHELL_VERSION=5.2.37
COPY scripts/8.36-bash.sh /lfs-scripts/8.36-bash.sh
RUN /lfs-scripts/8.36-bash.sh

# Now we can fix up this shell script from glibc to use the new bash
RUN sed -i -e 's/pass2/usr/' /usr/bin/ldd

# 8.37 libtool
ARG LIBTOOL_VERSION=2.5.4
COPY scripts/8.37-libtool.sh /lfs-scripts/8.37-libtool.sh
RUN /lfs-scripts/8.37-libtool.sh

# 8.42 Less
ARG LESS_VERSION=668
COPY scripts/8.42-less.sh /lfs-scripts/8.42-less.sh
RUN /lfs-scripts/8.42-less.sh

# 8.46 Autoconf
ARG AUTOCONF_VERSION=2.72
COPY scripts/8.46-autoconf.sh /lfs-scripts/8.46-autoconf.sh
RUN /lfs-scripts/8.46-autoconf.sh

# 8.47 Automake
ARG AUTOMAKE_VERSION=1.17
COPY scripts/8.47-automake.sh /lfs-scripts/8.47-automake.sh
RUN /lfs-scripts/8.47-automake.sh

# 8.48 OpenSSL
ARG OPENSSL_VERSION=3.4.1
COPY scripts/8.48-openssl.sh /lfs-scripts/8.48-openssl.sh
RUN /lfs-scripts/8.48-openssl.sh

# 8.49 Libelf
ARG LIBELF_VERSION=0.188
COPY scripts/8.49-libelf.sh /lfs-scripts/8.49-libelf.sh
RUN /lfs-scripts/8.49-libelf.sh

# 8.50 libffi
ARG LIBFFI_VERSION=3.4.2
COPY scripts/8.50-libffi.sh /lfs-scripts/8.50-libffi.sh
RUN /lfs-scripts/8.50-libffi.sh

# 8.55 - note that we install Ninja later in the BLFS section.

# 8.58 coreutils
ARG COREUTILS_VERSION=9.6
COPY scripts/8.58-coreutils.sh /lfs-scripts/8.58-coreutils.sh
RUN /lfs-scripts/8.58-coreutils.sh

# 8.60 diffutils
ARG DIFFUTILS_VERSION=3.11
COPY scripts/8.60-diffutils.sh /lfs-scripts/8.60-diffutils.sh
RUN /lfs-scripts/8.60-diffutils.sh

# 8.61 gawk
ARG GAWK_VERSION=5.3.1
COPY scripts/8.61-gawk.sh /lfs-scripts/8.61-gawk.sh
RUN /lfs-scripts/8.61-gawk.sh

# 8.62 findutils
ARG FINDUTILS_VERSION=4.10.0
COPY scripts/8.62-findutils.sh /lfs-scripts/8.62-findutils.sh
RUN /lfs-scripts/8.62-findutils.sh

# 8.65 gzip
ARG GZIP_VERSION=1.13
COPY scripts/8.65-gzip.sh /lfs-scripts/8.65-gzip.sh
RUN /lfs-scripts/8.65-gzip.sh

# 8.69 make
# Now we build make 4.4.1, rather than the earlier version we needed due
# to glibc.
ARG MAKE_VERSION=4.4.1
COPY scripts/8.69-make.sh /lfs-scripts/8.69-make.sh
RUN /lfs-scripts/8.69-make.sh

# 8.70 patch
ARG PATCH_VERSION=2.7.6
COPY scripts/8.70-patch.sh /lfs-scripts/8.70-patch.sh
RUN /lfs-scripts/8.70-patch.sh

# 8.71 tar
ARG TAR_VERSION=1.35
COPY scripts/8.71-tar.sh /lfs-scripts/8.71-tar.sh
RUN /lfs-scripts/8.71-tar.sh

# 8.78 procps-ng
ARG PROCPS_VERSION=4.0.5
COPY scripts/8.78-procps.sh /lfs-scripts/8.78-procps.sh
RUN /lfs-scripts/8.78-procps.sh

# 8.79 util-linux
ARG UTIL_LINUX_VERSION=2.40.4
COPY scripts/8.79-util-linux.sh /lfs-scripts/8.79-util-linux.sh
RUN /lfs-scripts/8.79-util-linux.sh

# Various cleanups and fixups
COPY scripts/8.xx-cleanup.sh /lfs-scripts/8.xx-cleanup.sh
RUN /lfs-scripts/8.xx-cleanup.sh

# 8.84 Strip everything
COPY scripts/8.84-stripping.sh /lfs-scripts/8.84-stripping.sh
RUN /lfs-scripts/8.84-stripping.sh

RUN rm -rf /lfs-scripts

FROM scratch AS blfs-stage1

#
# PASS 4: Build BLFS packages.
#

COPY --from=lfs-chroot / /
ENV PATH=/opt/gcc-13.2.0/bin:/usr/bin:/usr/sbin:/httpie/bin
ARG GNU_MIRROR=https://mirrors.ocf.berkeley.edu/gnu
ARG PARALLELISM=8

RUN mkdir /sources

# All we *really* want here is curl and git. However, curl requires
# libpsl, and libpsl in turn requires libidn2 and libunistring. So start
# by installing those.

# libunistring
ARG LIBUNISTRING_VERSION=1.3
COPY scripts/blfs-libunistring.sh /lfs-scripts/blfs-libunistring.sh
RUN /lfs-scripts/blfs-libunistring.sh

# libidn2
ARG LIBIDN2_VERSION=2.3.8
COPY scripts/blfs-libidn2.sh /lfs-scripts/blfs-libidn2.sh
RUN /lfs-scripts/blfs-libidn2.sh

# libpsl requires ninja to build. We're OK with this in the final image,
# although we install it from a binary download which in turn requires
# 7zip. Guess it's fine to have that in the final image too.

# 7zip (from binary package)
ARG SEVENZIP_VERSION=25.00
COPY scripts/blfs-7zip.sh /lfs-scripts/blfs-7zip.sh
RUN /lfs-scripts/blfs-7zip.sh

# ninja (from binary package)
ARG NINJA_VERSION=1.13.1
COPY scripts/blfs-ninja.sh /lfs-scripts/blfs-ninja.sh
RUN /lfs-scripts/blfs-ninja.sh

# However, libpsl and p11-kit also requires meson to build, which we
# DON'T want in the final image. We will install it temporarily using
# our good friend UV. UV will put everything (including itself) under
# /root/.local and /root/.cache. We will prune these afterwards.
ARG MESON_VERSION=1.7.0
ARG UV_VERSION=0.8.0
COPY scripts/blfs-meson-temp.sh /lfs-scripts/blfs-meson-temp.sh
RUN /lfs-scripts/blfs-meson-temp.sh

# libpsl
ARG LIBPSL_VERSION=0.21.5
COPY scripts/blfs-libpsl.sh /lfs-scripts/blfs-libpsl.sh
RUN /lfs-scripts/blfs-libpsl.sh

# Also, before we build curl, we need to install the CA certificates.
# LFS offers a useful tool to do the complex machinations for this,
# called make-ca. However, we don't need this tool in the final image.
# Also, make-ca requires p11-kit, which we'd prefer not to install in
# the final image. Unfortunately, make-ca really can't do its job
# without being installed globally. So, we're about to take a little
# side trip where we install p11-kit and make-ca into a temporary image,
# and then jump back to this image and just copy /etc/pki and /etc/ssl
# from the temporary image.

# First, though, p11-kit requires libtasn1, which we may as well have in
# the final image.
ARG LIBTASN1_VERSION=4.20.0
COPY scripts/blfs-libtasn1.sh /lfs-scripts/blfs-libtasn1.sh
RUN /lfs-scripts/blfs-libtasn1.sh

FROM blfs-stage1 AS blfs-make-ca

# make-ca, which also builds p11-kit
ARG MAKE_CA_VERSION=1.16.1
ARG P11_KIT_VERSION=0.25.5
COPY scripts/blfs-make-ca.sh /lfs-scripts/blfs-make-ca.sh
RUN /lfs-scripts/blfs-make-ca.sh

FROM blfs-stage1 AS blfs-stage2

# Now we can copy the CA certificates from the temporary image.
COPY --from=blfs-make-ca /etc/pki /etc/pki
COPY --from=blfs-make-ca /etc/ssl /etc/ssl

# At long last: curl!
ARG CURL_VERSION=8.15.0
COPY scripts/blfs-curl.sh /lfs-scripts/blfs-curl.sh
RUN /lfs-scripts/blfs-curl.sh

# Sudo
ARG SUDO_VERSION=1.9.17p1
COPY scripts/blfs-sudo.sh /lfs-scripts/blfs-sudo.sh
RUN /lfs-scripts/blfs-sudo.sh

# OpenSSH
ARG OPENSSH_VERSION=10.0p1
COPY scripts/blfs-openssh.sh /lfs-scripts/blfs-openssh.sh
RUN /lfs-scripts/blfs-openssh.sh

# Fake "which" from BLFS
COPY scripts/which /usr/bin/which

# Final strip. Re-use the script from step 8.84. Note: we do this before
# compiling git, because git makes heavy use of hard-linked files -
# stripping them after installation will break the hard links, consuming
# far more disk space.
COPY scripts/8.84-stripping.sh /lfs-scripts/8.84-stripping.sh
RUN /lfs-scripts/8.84-stripping.sh

# And finally, git.
ARG GIT_VERSION=2.50.1
COPY scripts/blfs-git.sh /lfs-scripts/blfs-git.sh
RUN /lfs-scripts/blfs-git.sh

# Final cleanup!
COPY scripts/blfs-cleanup.sh /lfs-scripts/blfs-cleanup.sh
RUN /lfs-scripts/blfs-cleanup.sh

# Flatten the final image.

FROM scratch AS docker-from-scratch
COPY --from=blfs-stage2 / /

RUN mkdir -pv /usr/local/bin
ENV PATH=/opt/gcc-13.2.0/bin:/usr/bin:/usr/local/bin:/usr/sbin
ENV LANG=en_US.UTF-8
CMD ["bash"]
