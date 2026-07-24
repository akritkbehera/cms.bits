package: collier
version: 1.2.8
sources:
 - https://cmsrep.cern.ch/cmssw/download/collier/%(version)s/%(package)s-%(version)s.tar.gz
build_requires:
 - gmake
 - CMake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sed -i 's;add_definitions(-Dcollierdd -DSING);add_definitions(-Dcollierdd -DSING -fPIC);g' "$BUILDDIR/CMakeLists.txt"

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=Release
    -Dstatic=ON
    -DCMAKE_Fortran_FLAGS=-fPIC
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

# Upstream parallel build is broken for Fortran module deps — keep -j1 (spec uses make -j1)
make -j1 -C "$BUILDDIR/build" ${VERBOSE:+VERBOSE=1}

# COLLIER's CMakeLists sets ARCHIVE/MODULE output dirs to the source tree,
# so the artifacts land in $BUILDDIR, not the cmake build dir
mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/include"
cp "$BUILDDIR/libcollier.a" "$INSTALLROOT/lib"
cp "$BUILDDIR/modules/"*.mod "$INSTALLROOT/include/"
