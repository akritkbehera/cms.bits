package: pcre2
version: "10.36"
variables:
  tag: pcre2-%(version)s
sources:
  - https://github.com/PCRE2Project/pcre2/archive/%(tag)s.tar.gz
requires:
 - bz2lib
 - zlib
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sh autogen.sh

./configure \
  --enable-unicode-properties \
  --enable-pcregrep-libz \
  --enable-pcregrep-libbz2 \
  --prefix=${INSTALLROOT} \
  CPPFLAGS="-I${BZ2LIB_ROOT}/include -I${ZLIB_ROOT}/include" \
  LDFLAGS="-L${BZ2LIB_ROOT}/lib -L${ZLIB_ROOT}/lib"

make ${JOBS:+-j$JOBS}
make install
