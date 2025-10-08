package: celeritas
version: v0.6.0
variables:
  celeritas_gitversion: shell(echo %(version)s | sed -e 's|^v||;s|-.*||')
  tag:                  dfa4cde7d7d65bf656b17a24c59fcc030aa6b0d9
sources:
- git+https://github.com/celeritas-project/celeritas?obj=develop/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
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
 - compilation_flags
 - compilation_flags_lto
---
export celeritas_gitversion=echo "%(version)s" | sed -e 's|^v||;s|-.*||'
export package_build_flags="-Wall -Wextra -pedantic"
export build_flags="${package_build_flags} -fPIC ${arch_build_flags} ${lto_build_flags} ${pgo_build_flags})"
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

rm -rf ../build
mkdir ../build
cd ../build

cmake $BUILDDIR \
    -DCeleritas_GIT_DESCRIBE="$celeritas_gitversion;;" \
    -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
    -DCMAKE_CXX_STANDARD:STRING="$CXXSTD" \
    -DCMAKE_AR=$(which gcc-ar) \
    -DCMAKE_RANLIB=$(which gcc-ranlib) \
    -DCMAKE_BUILD_TYPE=$LLVM_BUILD_TYPE \
    -DCMAKE_CXX_FLAGS="${build_flags}" \
    -DCMAKE_C_FLAGS="${build_flags}" \
    -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="${build_flags}" \
    -DCMAKE_STATIC_LIBRARY_C_FLAGS="${build_flags}" \
    -DCMAKE_PREFIX_PATH="%{cmake_prefix_path}" \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCELERITAS_BUILD_TESTS=OFF \
    -DCELERITAS_DEBUG=OFF \
    -DCELERITAS_USE_OpenMP=OFF \
    -DCELERITAS_USE_CUDA=OFF \
    -DCELERITAS_USE_Geant4=ON \
    -DCELERITAS_USE_HIP=OFF \
    -DCELERITAS_USE_HepMC3=OFF \
    -DCELERITAS_USE_JSON=ON \
    -DCELERITAS_USE_MPI=OFF \
    -DCELERITAS_USE_ROOT=OFF \
    -DCELERITAS_USE_SWIG=OFF \
    -DCELERITAS_USE_PNG=OFF \
