package: google-benchmark
version: 1.9.4
variables:
 commit: eddb0241389718a23a42db6af5f0164b6e0139af
 branch: main
sources:
 - git+https://github.com/google/benchmark.git?obj=%(branch)s/%(commit)s&export=benchmark-%(version)s-%(commit)s&module=benchmark-%(version)s-%(commit)s&output=/benchmark-%(version)s-%(commit)s.tgz
build_requires:
 - CMake
 - ninja
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR"

cmake_args=(
    -G Ninja
    -S "$BUILDDIR/benchmark-%(version)s-%(commit)s"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_CXX_FLAGS="-fPIE"
    -DCMAKE_BUILD_TYPE=Release
    -DBENCHMARK_ENABLE_GTEST_TESTS=OFF
    -DBENCHMARK_DOWNLOAD_DEPENDENCIES=OFF
)
cmake "${cmake_args[@]}"
ninja -v ${JOBS:+-j$JOBS} -C "$BUILDDIR/build"
ninja -v ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" install
