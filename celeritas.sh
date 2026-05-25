package: celeritas
version: 0.6.3
sources:
 - https://github.com/celeritas-project/celeritas/releases/download/v%(version)s/celeritas-%(version)s.tar.gz
 #- file://compilation-flags.file
variables:
 package_build_flags: "-Wall -Wextra -pedantic"
build_requires:
 - gmake
 - CMake
requires:
 - gcc
 - Python
 - json
 - geant4
 - clhep
 - expat
 - xerces-c
 - zlib
 - g4vg
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

chmod +x "$SOURCEDIR/${SOURCE1}"
./$SOURCEDIR/${SOURCE1}

make_args=(
    -B "$BUILDDIR/build"
    -S "$BUILDDIR"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_CXX_STANDARD:STRING="{$CXXSTD:-20}"
    -DCMAKE_AR="$(which gcc-ar)"
    -DCMAKE_RANLIB="$(which gcc-ranlib)"
    -DCMAKE_BUILD_TYPE="$cmake_build_type"
    -DCMAKE_CXX_FLAGS="$build_flags"
    -DCMAKE_C_FLAGS="$build_flags"
    -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="$build_flags"
    -DCMAKE_STATIC_LIBRARY_C_FLAGS="$build_flags"
    -DCMAKE_PREFIX_PATH="${GCC_ROOT};${PYTHON_ROOT};${JSON_ROOT};${GEANT4_ROOT};${CLHEP_ROOT};${EXPAT_ROOT};${XERCES_C_ROOT};${ZLIB_ROOT}"
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DCELERITAS_BUILD_TESTS=OFF
    -DCELERITAS_BUILTIN_G4VG:BOOL=OFF
    -DCELERITAS_DEBUG=OFF
    -DCELERITAS_USE_OpenMP=OFF
    -DCELERITAS_USE_CUDA=OFF
    -DCELERITAS_USE_Geant4=ON
    -DCELERITAS_USE_HIP=OFF
    -DCELERITAS_USE_HepMC3=OFF
    -DCELERITAS_USE_JSON=ON
    -DCELERITAS_USE_MPI=OFF
    -DCELERITAS_USE_ROOT=OFF
    -DCELERITAS_USE_SWIG=OFF
    -DCELERITAS_USE_PNG=OFF
)

if [ -n $VECGEOM_ROOT ]; then
    make_args+=(-DCELERITAS_USE_VecGeom=ON)
else
    make_args+=(-DCELERITAS_USE_VecGeom=OFF)
fi

cmake "${make_args[@]}"
make ${JOBS:+-j$JOBS} VERBOSE=1
make ${JOBS:+-j$JOBS} install VERBOSE=1
