package: tinyxml2
version: "11.0.0"
sources:
  - https://github.com/leethomason/%(package)s/archive/%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON

gmake -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
gmake -C "$BUILDDIR/build" install
