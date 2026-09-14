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
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCATCH_INSTALL_HELPERS=ON
    -DCATCH_INSTALL_EXTRAS=ON
    -DCMAKE_INSTALL_COMPONENT="devel"
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v}
ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v} install
