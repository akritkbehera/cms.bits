package: protobuf
version: "%(tag_basename)s"
tag: v3.21.9
sources:
- https://github.com/protocolbuffers/protobuf/archive/refs/tags/%(tag_basename)s.tar.gz
requires:
- gcc
- zlib
build_requires:
- CMake
- ninja
patches:
- protobuf_text_format.patch
- protobuf-non-virtual-dtor.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"

# Make sure the default c++std standard is c++11, then bump to the CMS standard
grep -q 'CMAKE_CXX_STANDARD  *11' CMakeLists.txt
sed -i -e 's|CMAKE_CXX_STANDARD  *11|CMAKE_CXX_STANDARD %(cms_cxx_std)s|' CMakeLists.txt

CMAKE_ARGS=(
    -G Ninja
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s
    -Dprotobuf_BUILD_TESTS=OFF
    -Dprotobuf_BUILD_SHARED_LIBS=ON
    -Dutf8_range_ENABLE_INSTALL=ON
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_CXX_FLAGS="-I${ZLIB_ROOT}/include"
    -DCMAKE_C_FLAGS="-I${ZLIB_ROOT}/include"
    -DCMAKE_SHARED_LINKER_FLAGS="-L${ZLIB_ROOT}/lib"
    -DCMAKE_PREFIX_PATH="${ZLIB_ROOT}"
)

cmake "${CMAKE_ARGS[@]}"

ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS}
ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS} install

mkdir -p "$INSTALLROOT/include/python/google/protobuf"
cp "$BUILDDIR/python/google/protobuf/"*.h "$INSTALLROOT/include/python/google/protobuf/"
rm -rf "$INSTALLROOT/lib/pkgconfig"
