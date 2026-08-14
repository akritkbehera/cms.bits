package: json
version: "3.12.0"
sources:
 - https://github.com/nlohmann/json/archive/refs/tags/v%(version)s.tar.gz
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
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DJSON_BuildTests=OFF \
  -DJSON_MultipleHeaders=OFF

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install
