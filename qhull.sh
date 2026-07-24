package: qhull
version: "8.0.2"
sources:
  - https://github.com/qhull/qhull/archive/refs/tags/v%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
  -S "$BUILDDIR" -B "$BUILDDIR/build"
  -DBUILD_STATIC_LIBS:BOOL=OFF
  -DBUILD_SHARED_LIBS:BOOL=ON
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_INSTALL_PREFIX:STRING="$INSTALLROOT"
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi
cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install
