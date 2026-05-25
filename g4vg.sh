package: g4vg
version: 1.0.6
sources:
  - https://github.com/celeritas-project/g4vg/releases/download/v%(version)s/g4vg-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - geant4
  - vecgeom
  - clhep
  - expat
  - xerces-c
  - zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$BUILDROOT/build"
cd "$BUILDROOT/build"

cmake "$BUILDDIR" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_CXX_STANDARD="$CXXSTD" \
  -DCMAKE_AR=$(which gcc-ar) \
  -DCMAKE_RANLIB=$(which gcc-ranlib) \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-fPIC -Wall -Wextra -pedantic" \
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC -Wall -Wextra -pedantic" \
  -DCMAKE_PREFIX_PATH="${GEANT4_ROOT};${VECGEOM_ROOT};${CLHEP_ROOT};${EXPAT_ROOT};${XERCESC_ROOT};${ZLIB_ROOT}" \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DG4VG_BUILD_TESTS=OFF \
  -DG4VG_DEBUG=OFF

make ${JOBS:+-j$JOBS} VERBOSE=1
make install VERBOSE=1

