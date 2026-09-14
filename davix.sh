package: davix
version: "R_0_8_9"
sources:
  - git+https://github.com/cern-fts/davix.git?obj=devel/%(version)s&export=%(package)s-%(version)s&submodules=1&output=/%(package)s-%(version)s.tgz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
 - libxml2
 - libuuid
 - curl
 - Python
 - zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DRAPIDJSON_HAS_STDSTRING=1
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DEMBEDDED_LIBCURL=FALSE
    -DDAVIX_TESTS=False
    -DUUID_LIBRARY="${LIBUUID_ROOT}/lib64/libuuid.so"
    -DCMAKE_PREFIX_PATH="${LIBXML2_ROOT};${LIBUUID_ROOT};${CURL_ROOT}"
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

make VERBOSE=1 ${JOBS:+-j$JOBS} -C "$BUILDDIR/build"
make -C "$BUILDDIR/build" install
