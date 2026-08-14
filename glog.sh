package: glog
version: "0.7.1"
sources:
  - https://github.com/google/glog/archive/refs/tags/v%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=17 \
  -DBUILD_SHARED_LIBS=ON \
  -DWITH_GTEST=OFF \
  -DWITH_GFLAGS=OFF \
  -DWITH_UNWIND=OFF
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
