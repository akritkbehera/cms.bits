package: google-test
version: 1.17.0
variables:
  commit: 52eb8108c5bdec04579160ae17225d66034bd723
  branch: v1.17.x
sources:
  - git+https://github.com/google/googletest.git?obj=%(branch)s/%(commit)s&export=googletest-%(version)s&output=/googletest-%(version)s.tgz
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

# Builds static libgtest + libgtest_main (the latter backs the google-test-main tool).
# GMOCK off, -fPIC so the archives can be linked into shared libraries.
CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -G Ninja
    -DCMAKE_INSTALL_PREFIX:STRING="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCMAKE_CXX_FLAGS="-fPIC"
    -DBUILD_GMOCK=OFF
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v}
ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v} install
