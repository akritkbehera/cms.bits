package: libzip
version: "1.11.4"
sources:
  - https://github.com/nih-at/libzip/releases/download/v%(version)s/libzip-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - zlib
  - zstd
  - xz
  - bz2lib
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
  -S "$BUILDDIR"
  -B "$BUILDDIR/build"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_PREFIX_PATH="$ZLIB_ROOT;$ZSTD_ROOT;$XZ_ROOT;$BZ2LIB_ROOT"
  -DENABLE_COMMONCRYPTO=OFF
  -DENABLE_GNUTLS=OFF
  -DENABLE_MBEDTLS=OFF
  -DENABLE_WINDOWS_CRYPTO=OFF
  -DBUILD_EXAMPLES=OFF
  -DBUILD_DOC=OFF
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
