package: dd4hep
version: v01-37x
tag: ed75e7e233b068cbe2cd5eb50a82a80da27ad99b
source: https://github.com/AIDASoft/DD4hep.git
build_requires:
 - CMake
 - gmake
requires:
 - gcc
 - clhep
 - expat
 - xerces-c
 - vecgeom
 - zlib
 - ROOT
 - boost
 - geant4
 - json
---
export build_flags="-fPIC $arch_build_flags $lto_build_flags $pgo_build_flags"

rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

export BOOST_ROOT

cmake_fixed_args=(
    "-DCMAKE_INSTALL_PREFIX=$INSTALLROOT"
    "-DCMAKE_CXX_FLAGS=${build_flags}"
    "-DCMAKE_STATIC_LIBRARY_CXX_FLAGS=${build_flags}"
    "-DCMAKE_STATIC_LIBRARY_C_FLAGS=${build_flags}"
    "-DBoost_NO_BOOST_CMAKE=ON"
    "-DDD4HEP_USE_XERCESC=ON"
    "-DDD4HEP_USE_PYROOT=ON"
    "-DCMAKE_AR=${GCC_ROOT}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${GCC_ROOT}/bin/gcc-ranlib"
    "-DCMAKE_CXX_STANDARD=%(cms_cxx_std)s"
    "-DCMAKE_BUILD_TYPE=%(cms_build_type)s"
    "-DDD4HEP_USE_GEANT4_UNITS=ON"
    "-DXERCESC_ROOT_DIR=${XERCES_C_ROOT}"
    "-DCMAKE_PREFIX_PATH=$CLHEP_ROOT;$EXPAT_ROOT;$XERCES_C_ROOT;$VECGEOM_ROOT;$ZLIB_ROOT;$ROOT_ROOT;$BOOST_ROOT;$GEANT4_ROOT;$GCC_ROOT;$JSON_ROOT"
)

# Build normal shared DD4hep without Geant4
cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
    "${cmake_fixed_args[@]}" -DBUILD_SHARED_LIBS=ON -DDD4HEP_USE_GEANT4=OFF
make -C "$BUILDDIR/build" ${JOBS:+-j "$JOBS"} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1

# Build DDG4 static
cmake -S "$BUILDDIR" -B "$BUILDDIR/build-g4" \
    "${cmake_fixed_args[@]}" -DBUILD_SHARED_LIBS=OFF -DDD4HEP_USE_GEANT4=ON
make -C "$BUILDDIR/build-g4/DDG4" ${JOBS:+-j "$JOBS"} VERBOSE=1

for lib in "$BUILDDIR/build-g4/lib"/libDDG4*.a; do
    base=$(basename "$lib" .a)
    mv "$lib" "$INSTALLROOT/lib/${base}-static.a"
done

mv "$BUILDDIR/DDG4/include/DDG4" "$INSTALLROOT/include"
