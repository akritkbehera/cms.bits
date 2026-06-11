package: gbl
version: V04-00-00
variables:
 tag: 6e60cdf1f1a296ce0a4e08833ebbfa58e9ad2787
sources:
 - git+https://gitlab.desy.de/millepede/general-broken-lines.git?obj=main/%(tag)s&export=%(version)s-%(version)s&output=/%(package)s-%(version)s.tgz
build_requires:
 - CMake
requires:
 - eigen
 - mille
 - "gcc:(?gcc)"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

grep -q 'CMAKE_CXX_STANDARD  *17' cpp/CMakeLists.txt
sed -i -e "s|CMAKE_CXX_STANDARD  *17|CMAKE_CXX_STANDARD $CXXSTD|" cpp/CMakeLists.txt

rm -rf ../build && mkdir -p ../build && cd ../build

cmake $BUILDDIR/cpp \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$DCMAKE_BUILD_TYPE \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DEIGEN3_INCLUDE_DIR=${EIGEN_ROOT}/include/eigen3 \
  -DSUPPORT_ROOT=False \
  -DCMAKE_CXX_FLAGS="$CMS_EIGEN_CXX_FLAGS ${selected_microarch}"

make ${JOBS:+-j$JOBS}
make install
