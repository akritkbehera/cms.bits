package: hepmc
version: 2.06.10
variables:
  tag: 97620c648f31c9129b42c0b38fe4bd1ddfee9cab
sources:
  - https://github.com/cms-externals/hepmc/archive/%(tag)s.tar.gz
build_requires:
  - CMake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDROOT/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_CXX_FLAGS="-fPIC"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s
    -Dmomentum:STRING=GEV
    -Dlength:STRING=MM
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDROOT/build" ${JOBS:+-j$JOBS}
make -C "$BUILDROOT/build" install

rm -rf $INSTALLROOT/lib/*.so
rm -rf $INSTALLROOT/lib/*.la
