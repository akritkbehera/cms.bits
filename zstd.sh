package: zstd
version: "1.5.7"
variables:
  tag: v%(version)s
sources:
  - https://github.com/facebook/zstd/archive/%(tag)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
env:
  ZSTD_SOURCE: https://github.com/facebook/zstd/releases/download/v%(version)s/zstd-%(version)s.tar.gz
  ZSTD_STRIP_PREFIX: zstd-%(version)s
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake build/cmake \
 -DZSTD_BUILD_CONTRIB:BOOL=OFF \
 -DZSTD_BUILD_STATIC:BOOL=OFF \
 -DZSTD_BUILD_TESTS:BOOL=OFF \
 -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
 -DZSTD_BUILD_PROGRAMS:BOOL=OFF \
 -DZSTD_LEGACY_SUPPORT:BOOL=OFF \
 -DCMAKE_INSTALL_PREFIX:STRING=$INSTALLROOT \
 -DCMAKE_INSTALL_LIBDIR:STRING=lib \
 -Dzstd_VERSION:STRING=${PKGVERSION}

make ${JOBS:+-j$JOBS}
make install
