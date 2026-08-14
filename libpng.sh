package: libpng
version: "1.6.44"
sources:
 - https://github.com/pnggroup/libpng/archive/refs/tags/v%(version)s.tar.gz
build_requires:
  - autotools
  - gmake
requires:
  - gcc
  - zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -fiv

./configure \
  --prefix="$INSTALLROOT" \
  --disable-silent-rules \
  CPPFLAGS="-I${ZLIB_ROOT}/include" \
  LDFLAGS="-L${ZLIB_ROOT}/lib"

make ${JOBS:+-j$JOBS}
make install
