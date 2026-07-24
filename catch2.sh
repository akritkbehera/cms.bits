package: catch2
version: 3.13.0
sources:
 - https://github.com/catchorg/Catch2/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
 - ninja
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -G Ninja
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCMAKE_CXX_COMPILER=$(which gcc)
    -DCMAKE_INSTALL_PREFIX:STRING="$INSTALLROOT"
    -DDEACTIVATE_LZ4:BOOL=OFF
    -DDEACTIVATE_SNAPPY:BOOL=ON
    -DDEACTIVATE_ZLIB:BOOL=OFF
    -DDEACTIVATE_ZSTD:BOOL=OFF
    -DDEACTIVATE_AVX2:BOOL=ON
    -DDEACTIVATE_SSE2:BOOL=ON
    -DPREFER_EXTERNAL_ZSTD=ON
    -DPREFER_EXTERNAL_LZ4=ON
    -DPREFER_EXTERNAL_ZLIB=ON
    -DCMAKE_PREFIX_PATH="$ZLIB_ROOT;$ZSTD_ROOT;$LZ4_ROOT"
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v}
ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v} install
