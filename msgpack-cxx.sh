package: msgpack-cxx
version: "7.0.0"
sources:
  - https://github.com/msgpack/msgpack-c/releases/download/cpp-%(version)s/msgpack-cxx-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - boost
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_PREFIX_PATH="$BOOST_ROOT" \
  -DCMAKE_CXX_STANDARD="%(cms_cxx_std)s" \
  -DMSGPACK_BUILD_DOCS=off
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
