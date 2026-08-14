package: gbl
version: V04-00-00
variables:
 tag: 6e60cdf1f1a296ce0a4e08833ebbfa58e9ad2787
sources:
 - git+https://gitlab.desy.de/millepede/general-broken-lines.git?obj=main/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
build_requires:
 - CMake
requires:
 - gcc
 - eigen
 - mille
---
#!include <microarch-flags.file>

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

grep -q 'CMAKE_CXX_STANDARD  *17' "$BUILDDIR/cpp/CMakeLists.txt"
sed -i -e 's|CMAKE_CXX_STANDARD  *17|CMAKE_CXX_STANDARD %(cms_cxx_std)s|' "$BUILDDIR/cpp/CMakeLists.txt"

CMAKE_ARGS=(
    -S "$BUILDDIR/cpp"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCMAKE_VERBOSE_MAKEFILE=ON
    -DEIGEN3_INCLUDE_DIR="${EIGEN_ROOT}/include/eigen3"
    -DSUPPORT_ROOT=False
    -DCMAKE_PREFIX_PATH="${GCC_ROOT};${EIGEN_ROOT};${MILLE_ROOT}"
    -DCMAKE_CXX_FLAGS="$CMS_EIGEN_CXX_FLAGS ${selected_microarch}"
)

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
