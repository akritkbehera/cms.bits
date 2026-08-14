package: davix
version: "%(tag_basename)s"
tag: R_0_8_9
source: https://github.com/cern-fts/davix
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
cd $SOURCEDIR
git submodule update --recursive --init
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
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
