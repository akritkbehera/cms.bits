package: catch2
version: 3.11.0
sources:
 -  https://github.com/catchorg/Catch2/archive/refs/tags/v%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build; mkdir ../build; cd ../build

cmake $BUILDDIR \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCATCH_INSTALL_HELPERS=ON \
  -DCATCH_INSTALL_EXTRAS=ON

make ${JOBS:+-j$JOBS}
make install
