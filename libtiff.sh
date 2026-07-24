package: libtiff
version: "4.6.0"
sources:
 - https://github.com/libsdl-org/libtiff/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - autotools
 - gmake
requires:
 - gcc
 - libjpeg-turbo
 - zlib
 - xz
 - zstd
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -fiv

./configure --prefix=${INSTALLROOT} --disable-static \
  --with-zstd-lib-dir=${ZSTD_ROOT}/lib \
  --with-zstd-include-dir=${ZSTD_ROOT}/include \
  --with-lzma-lib-dir=${XZ_ROOT}/lib \
  --with-lzma-include-dir=${XZ_ROOT}/include \
  --with-zlib-lib-dir=${ZLIB_ROOT}/lib \
  --with-zlib-include-dir=${ZLIB_ROOT}/include \
  --with-jpeg-lib-dir=${LIBJPEG_TURBO_ROOT}/lib64 \
  --with-jpeg-include-dir=${LIBJPEG_TURBO_ROOT}/include \
  --disable-dependency-tracking \
  --without-x

make ${JOBS:+-j$JOBS}
make install

rm -f ${INSTALLROOT}/lib/*.{l,}a
