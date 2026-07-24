package: geant4-parfullcms
version: "2014.01.27"
sources:
  # cmsdist's original davidlt.web.cern.ch vault URL is dead; the cms-externals GitHub
  # mirror carries the same 2014.01.27 sources.
  - https://github.com/cms-externals/parfullcms/archive/refs/tags/%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - geant4
  - geant4data
---
# The GitHub archive unpacks to parfullcms-<version>/ with CMakeLists.txt at its root.
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
SRC="$BUILDDIR"

# CMakeLists.txt still lists a plain 'README' among the files it configure_file()s, but the
# GitHub mirror renamed it to README.md. Provide the expected name so the copy step succeeds.
[ -f "$SRC/README" ] || cp "$SRC/README.md" "$SRC/README"

# Geant4 11 replaced the static G4VisAttributes::Invisible member with GetInvisible().
# This 2014 snapshot predates the change (cmsdist's now-dead vault tarball carried newer code).
sed -i 's/G4VisAttributes::Invisible\b/G4VisAttributes::GetInvisible()/g' \
  "$SRC/src/MyDetectorConstruction.cc"

CMAKE_ARGS=(
  -S "$SRC" -B "$SRC/build-ParFullCMS"
  -DCMAKE_CXX_COMPILER="g++"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
  -DCMAKE_INSTALL_LIBDIR="lib"
  -DBUILD_SHARED_LIBS=OFF
  -DBUILD_STATIC_LIBS=ON
  -DGeant4_USE_FILE="${GEANT4_ROOT}"
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi
cmake "${CMAKE_ARGS[@]}"

make -C "$SRC/build-ParFullCMS" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$SRC/build-ParFullCMS" install VERBOSE=1
