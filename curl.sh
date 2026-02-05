package: curl
version: "7.79.0"
sources: 
 - https://curl.se/download/curl-%(version)s.tar.gz
requires:
  - zlib
  - gcc
---
tar -xzf "$SOURCEDIR/$SOURCE0" \
  --strip-components=1 \
  -C "$BUILDDIR"

if [[ "$OSTYPE" == "darwin"* ]]; then
    KERBEROS_ROOT=/usr/heimdal
    OS_TYPE="darwin"
else
    KERBEROS_ROOT=/usr
    OS_TYPE="linux"
fi

./configure \
  --prefix="$INSTALLROOT" \
  --disable-silent-rules \
  --disable-static \
  --without-libidn \
  --without-zstd \
  --disable-ldap \
  --with-zlib="$ZLIB_ROOT" \
  --without-nss \
  --without-libssh2 \
  --with-gssapi="$KERBEROS_ROOT" \
  --with-openssl

make ${JOBS:+-j$JOBS}
make install
rm -rf $INSTALLROOT/lib/pkgconfig
