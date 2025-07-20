#!/pass2/bin/bash -ex

cd /sources
download https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.xz
tar -xf perl-${PERL_VERSION}.tar.xz
cd perl-${PERL_VERSION}

sh Configure -des                                         \
             -D prefix=/pass2                             \
             -D vendorprefix=/pass2                         \
             -D useshrplib                                \
             -D privlib=/pass2/lib/perl5/5.40/core_perl     \
             -D archlib=/pass2/lib/perl5/5.40/core_perl     \
             -D sitelib=/pass2/lib/perl5/5.40/site_perl     \
             -D sitearch=/pass2/lib/perl5/5.40/site_perl    \
             -D vendorlib=/pass2/lib/perl5/5.40/vendor_perl \
             -D vendorarch=/pass2/lib/perl5/5.40/vendor_perl
make -j${PARALLELISM}
make install

cd /sources
rm -rf perl-${PERL_VERSION} perl-${PERL_VERSION}.tar.xz
