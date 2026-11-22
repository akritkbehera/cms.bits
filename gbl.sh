package: gbl
version: V04-00-08
sources:
 - https://gitlab.desy.de/millepede/general-broken-lines/-/archive/%(version)s/general-broken-lines-%(version)s.tar.gz
build_requires:
 - CMake
requires:
 - gcc
 - eigen
 - mille
 - zlib
 - ROOT
---
#!include <microarch-flags.file>

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -S "$BUILDDIR/cpp"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s
    -DCMAKE_VERBOSE_MAKEFILE=ON
    -DEIGEN3_INCLUDE_DIR="${EIGEN_ROOT}/include/eigen3"
    -DSUPPORT_ROOT=False
    -DCMAKE_PREFIX_PATH="${GCC_ROOT};${EIGEN_ROOT};${MILLE_ROOT}"
    -DCMAKE_CXX_FLAGS="$CMS_EIGEN_CXX_FLAGS ${selected_microarch}"
)

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
