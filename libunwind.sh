package: libunwind
version: "1.8.3"
sources:
  - https://github.com/%(package)s/%(package)s/archive/refs/tags/v%(version)s.tar.gz
  - https://patch-diff.githubusercontent.com/raw/libunwind/libunwind/pull/831.patch
build_requires:
  - autotools
  - gmake
requires:
  - zlib
  - xz
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/${SOURCE1}"

autoreconf -fiv

./configure CFLAGS="-g -O3 -fcommon" \
  CPPFLAGS="-I${ZLIB_ROOT}/include -I${XZ_ROOT}/include" \
  LDFLAGS="-L${ZLIB_ROOT}/lib -L${XZ_ROOT}/lib" \
  --disable-tests \
  --prefix=$INSTALLROOT --disable-block-signals --enable-zlibdebuginfo --disable-per-thread-cache

make ${JOBS:+-j$JOBS}
make ${JOBS:+-j$JOBS} install

if [ -d "$INSTALLROOT/lib64" ]; then
  mkdir -p "$INSTALLROOT/lib"
  mv "$INSTALLROOT/lib64/"* "$INSTALLROOT/lib/"
  rmdir "$INSTALLROOT/lib64"
fi
