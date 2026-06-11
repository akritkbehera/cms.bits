package: flatbuffers
version: "24.3.25"
variables:
 tag: v%(version)s
 branch: master
 github_user: google
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
 - CMake
 - gmake
requires:
 - "gcc:(?gcc)"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake_args=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_BUILD_TYPE=Release
    -DFLATBUFFERS_BUILD_CPP17=ON
    -DFLATBUFFERS_CPP_STD="${CXXSTD:-20}"
    -DFLATBUFFERS_BUILD_SHAREDLIB=ON
    -DFLATBUFFERS_BUILD_TESTS=OFF
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
)
cmake "${cmake_args[@]}"
make -v ${JOBS:+-j$JOBS} -C "$BUILDDIR/build"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" install
