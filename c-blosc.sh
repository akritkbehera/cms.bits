package: c-blosc
version: "1.21.6"
sources:
 - https://github.com/Blosc/c-blosc/archive/refs/tags/v%(version)s.tar.gz
requires:
 - zlib
 - zstd
 - lz4
 - gcc
 - ninja
build_requires:
 - CMake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -G Ninja
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
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

cmake -S "$BUILDDIR" -B "$BUILDROOT/build" "${CMAKE_ARGS[@]}"

ninja -C "$BUILDROOT/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v} install
