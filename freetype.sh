package: FreeType
version: 2-14-3
sources:
  - https://github.com/freetype/freetype/archive/refs/tags/VER-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - bz2lib
  - zlib
  - libpng
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$BUILDDIR/build"
cd "$BUILDDIR/build"

cmake "$BUILDDIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DFT_DISABLE_HARFBUZZ=TRUE \
  -DFT_REQUIRE_ZLIB=TRUE \
  -DFT_REQUIRE_BZIP2=TRUE \
  -DFT_REQUIRE_PNG=TRUE \
  -DCMAKE_PREFIX_PATH="${BZ2LIB_ROOT};${ZLIB_ROOT};${LIBPNG_ROOT}" \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"

make ${JOBS:+-j$JOBS} VERBOSE=1
make install
