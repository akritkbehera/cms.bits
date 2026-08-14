package: TBB
version: "%(tag_basename)s"
tag: v2022.3.0
source: https://github.com/uxlfoundation/oneTBB
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - hwloc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_CXX_FLAGS="-Wno-error=use-after-free -Wno-error=address -Wno-error=uninitialized" \
      -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s \
      -DCMAKE_INSTALL_PREFIX=${INSTALLROOT} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_HWLOC_2_5_INCLUDE_PATH=$HWLOC_ROOT/include \
      -DCMAKE_HWLOC_2_5_LIBRARY_PATH=$HWLOC_ROOT/lib/libhwloc.so \
      -DTBB_CPF=ON \
      -DTBB_TEST=OFF

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install