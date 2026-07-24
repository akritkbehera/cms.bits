package: c-blosc2
version: 3.2.1
sources:
 - https://github.com/Blosc/c-blosc2/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - ninja
 - CMake
requires:
 - zlib
 - zstd
 - lz4
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build; mkdir ../build; cd ../build

cmake $BUILDDIR \
 -G Ninja \
 -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
 -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT \
 -DDEACTIVATE_ZLIB:BOOL=OFF \
 -DDEACTIVATE_ZSTD:BOOL=OFF \
 -DDEACTIVATE_AVX2:BOOL=ON \
 -DPREFER_EXTERNAL_ZSTD=ON \
 -DPREFER_EXTERNAL_LZ4=ON \
 -DPREFER_EXTERNAL_ZLIB=ON \
 -DCMAKE_C_FLAGS="-I${LZ4_ROOT}/include" \
 -DCMAKE_PREFIX_PATH="$ZLIB_ROOT;$ZSTD_ROOT;$LZ4_ROOT"

ninja -v ${JOBS:+-j$JOBS} 
ninja -v ${JOBS:+-j$JOBS} install
