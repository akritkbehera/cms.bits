package: lwtnn
version: 2.14.1
sources: 
  - https://github.com/lwtnn/lwtnn/archive/v%(version)s.tar.gz
build_requires:
  - ninja
  - CMake
requires:
  - gcc
  - microarch-flag
  - eigen
  - boost
  - scram-tools-flag
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build && mkdir -p ../build && cd ../build

cmake $BUILDDIR \
  -G Ninja \
  -DCMAKE_CXX_COMPILER="g++" \
  -DCMAKE_CXX_FLAGS="-fPIC $CMS_EIGEN_CXX_FLAGS ${selected_microarch}" \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILTIN_BOOST=OFF \
  -DBUILTIN_EIGEN=OFF \
  -DCMAKE_PREFIX_PATH="${EIGEN_ROOT};${BOOST_ROOT}" \
  -DCMAKE_CXX_STANDARD=$CXXSTD


ninja -v ${JOBS:+-j $JOBS}
ninja -v ${JOBS:+-j $JOBS} install

