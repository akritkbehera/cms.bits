package: re2
version: "2021_06_01"
tag: "2021-06-01"
source: https://github.com/google/re2/
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

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
