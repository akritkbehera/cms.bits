package: libyaml
version: "0.2.5"
sources:
 - https://github.com/yaml/libyaml/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_BUILD_TYPE="$DCMAKE_BUILD_TYPE" \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
cmake --build "$BUILDDIR/build" --parallel "${JOBS:-1}"
cmake --install "$BUILDDIR/build"
