package: google-test
version: 1.17.0
variables:
  commit: 52eb8108c5bdec04579160ae17225d66034bd723
  branch: v1.17.x
sources:
  - git+https://github.com/google/googletest.git?obj=%(branch)s/%(commit)s&export=googletest-%(version)s-%(commit)s&module=googletest-%(version)s-%(commit)s&output=/googletest-%(version)s-%(commit)s.tgz
build_requires:
  - CMake
  - ninja
requires:
  - "gcc:(?gcc)"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$BUILDDIR/build"
cd "$BUILDDIR/build"

cmake "$BUILDDIR" \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_CXX_FLAGS="-fPIC" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_GMOCK=OFF

ninja -v ${JOBS:+-j$JOBS}
ninja -v ${JOBS:+-j$JOBS} install
