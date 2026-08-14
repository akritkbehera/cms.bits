package: celeritas
version: 0.7.0-devX
variables:
  tag: 1fb77992ff4a8b6da8cc8d8630df3727a3c33cf3
  branch: develop
  github_user: celeritas-project
sources:
 - git+https://github.com/%(github_user)s/celeritas.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
build_requires:
 - gmake
 - CMake
requires:
 - gcc
 - Python
 - json
 - geant4
 - vecgeom
 - clhep
 - expat
 - xerces-c
 - zlib
 - g4vg
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

build_flags="-Wall -Wextra -pedantic -fPIC"

use_vecgeom=OFF
[ -n "$VECGEOM_REVISION" ] && use_vecgeom=ON

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_CXX_STANDARD:STRING="%(cms_cxx_std)s"
    -DCMAKE_AR="$(which gcc-ar)"
    -DCMAKE_RANLIB="$(which gcc-ranlib)"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCMAKE_CXX_FLAGS="$build_flags"
    -DCMAKE_C_FLAGS="$build_flags"
    -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="$build_flags"
    -DCMAKE_STATIC_LIBRARY_C_FLAGS="$build_flags"
    -DCMAKE_PREFIX_PATH="${GCC_ROOT};${PYTHON_ROOT};${JSON_ROOT};${GEANT4_ROOT};${VECGEOM_ROOT};${CLHEP_ROOT};${EXPAT_ROOT};${XERCES_C_ROOT};${ZLIB_ROOT};${G4VG_ROOT}"
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
    -DCELERITAS_USE_VecGeom="$use_vecgeom"
    -DVecCore_DIR="${VECGEOM_ROOT}/lib64/cmake/VecCore"
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

cmake --build "$BUILDDIR/build" ${JOBS:+--parallel "$JOBS"} ${VERBOSE:+--verbose}
cmake --install "$BUILDDIR/build"
