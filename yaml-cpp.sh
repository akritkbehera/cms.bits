package: yaml-cpp
version: "v%(tag_basename)s"
tag: "0.8.0"
build_requires:
- CMake
- ninja
requires:
- gcc
sources:
- https://github.com/jbeder/yaml-cpp/archive/refs/tags/%(tag_basename)s.tar.gz
- https://github.com/jbeder/yaml-cpp/commit/7b469b4220f96fb3d036cf68cd7bd30bd39e61d2.diff
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/${SOURCE1}"

rm -rf build
mkdir build
cd build

cmake \
  -G Ninja \
  -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DYAML_BUILD_SHARED_LIBS=ON \
  -DYAML_CPP_BUILD_TESTS=OFF \
  ..

ninja -v ${JOBS:+-j$JOBS} 
ninja install
