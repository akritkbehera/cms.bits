package: flatbuffers
version: "24.3.25"
sources:
 - https://github.com/google/flatbuffers/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
prepend_path:
  LD_LIBRARY_PATH: $FLATBUFFERS_ROOT/lib64
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DFLATBUFFERS_BUILD_CPP17=ON
    -DFLATBUFFERS_CPP_STD=%(cms_cxx_std)s
    -DFLATBUFFERS_BUILD_SHAREDLIB=ON
    -DFLATBUFFERS_BUILD_TESTS=OFF
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} ${VERBOSE:+VERBOSE=1}
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} install
