package: heaptrack
version: "1.4.0"
sources:
 - https://github.com/KDE/heaptrack/archive/refs/tags/v%(version)s.tar.gz
 - https://invent.kde.org/sdk/heaptrack/-/commit/c6c45f3455a652c38aefa402aece5dafa492e8ab.patch
 - https://github.com/KDE/heaptrack/commit/99348321819fe8efb3771b2dcd9aaffbc598b271.patch
build_requires:
 - CMake
requires:
 - boost
 - libunwind
 - zstd
 - bz2lib
 - zlib
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/${SOURCE1}"
# Drops the Boost.System component requirement, which boost >=1.69 no longer ships.
patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/${SOURCE2}"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
   -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
   -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
   -DCMAKE_VERBOSE_MAKEFILE=TRUE \
   -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-g -O3" \
   -DCMAKE_PREFIX_PATH="${LIBUNWIND_ROOT};${BOOST_ROOT};${ZSTD_ROOT};${BZ2LIB_ROOT};${ZLIB_ROOT}" \
   -DHEAPTRACK_BUILD_GUI=off \
   -DHEAPTRACK_USE_LIBUNWIND=on \
   -DHEAPTRACK_BUILD_PRINT=on

cmake --build "$BUILDDIR/build" ${JOBS:+--parallel $JOBS} -- DEBUG=1 VERBOSE=1
cmake --install "$BUILDDIR/build"
