package: FreeType
version: "2-14-3"
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

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_BUILD_TYPE=Release
    -DFT_DISABLE_HARFBUZZ=TRUE
    -DFT_REQUIRE_ZLIB=TRUE
    -DFT_REQUIRE_BZIP2=TRUE
    -DFT_REQUIRE_PNG=TRUE
    -DCMAKE_PREFIX_PATH="${GCC_ROOT};${BZ2LIB_ROOT};${ZLIB_ROOT};${LIBPNG_ROOT}"
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install
