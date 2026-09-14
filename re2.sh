package: re2
version: "2021_06_01"
variables:
  tag: "2021-06-01"
sources:
  - https://github.com/google/re2/archive/%(tag)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake \
  -S "$BUILDDIR" \
  -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DBUILD_SHARED_LIBS=True \
  -DCMAKE_POSITION_INDEPENDENT_CODE=True \
  -DCMAKE_INSTALL_LIBDIR=lib

make -C "$BUILDDIR/build" VERBOSE=1 ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
