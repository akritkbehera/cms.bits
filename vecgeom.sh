package: vecgeom
version: "1.2.11"
tag: 47dd602df7074fcc78036e93cd639ae6270207fd
sources: 
- git+https://gitlab.cern.ch/vecgeom/vecgeom.git?obj=master/%(tag_basename)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
patches:
- vecgeom-fix-vector.patch
build_requires:
- CMake 
- gmake
requires:
- xerces-c
---
export VECGEOM_BACKEND="scalar"
tar -xzf "$SOURCEDIR/$SOURCE0" \
    --strip-components=1 \
    -C "$BUILDDIR" 

patch -p1 < $SOURCEDIR/$PATCH0

if [ -z "$microarch" ]; then
  microarch="-march=x86-64-v3"
fi
echo $microarch
SEL_ARCH=$(echo ${microarch} | sed 's|^-m||')
echo $SEL_ARCH
VECGEOM_VECTOR_INST="$(grep ' set(VECGEOM_ISAS ' CMakeLists.txt | tr ' ' '\n' | grep -E "^${SEL_ARCH}$")"
echo $VECGEOM_VECTOR_INST

cmake_args=(
  -DVecGeom_GIT_DESCRIBE="$PKG_VERSION"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DBUILD_TESTING=OFF
  -DVecGeom_VERSION="$PKG_VERSION"
  -DCMAKE_CXX_STANDARD:STRING="$CXXSTD"
  -DCMAKE_AR="$(which gcc-ar)"
  -DCMAKE_RANLIB="$(which gcc-ranlib)"
  -DCMAKE_BUILD_TYPE="$LLVM_BUILD_TYPE"
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG $BUILDFLAGS"
  -DCMAKE_VERBOSE_MAKEFILE=TRUE
  -DCMAKE_SHARED_LIBRARY=OFF
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="$BUILDFLAGS"
  -DCMAKE_STATIC_LIBRARY_C_FLAGS="$BUILDFLAGS"  
  -DCMAKE_CXX_FLAGS="$BUILDFLAGS"
  -DCMAKE_C_FLAGS="$BUILDFLAGS"
  -DVECGEOM_NO_SPECIALIZATION=ON
  -DVECGEOM_BUILTIN_VECCORE=ON
  -DVECGEOM_BACKEND="$VECGEOM_BACKEND"
  -DVECGEOM_GEANT4=OFF
  -DVECGEOM_ROOT=OFF
  -DCMAKE_PREFIX_PATH="$XERCES_C_ROOT"
  )

if [[ $VECGEOM_BACKEND == "Vc" ]]; then
  cmake_args+=(
    -DVECGEOM_VECTOR="${VECGEOM_VECTOR_INST}" 
  )
fi

cmake "${cmake_args[@]}"
make ${jobs:+-j$jobs}
make install verbose=1


sed -i -e 's|set(VecCore_DIR .*|set(VecCore_DIR "$INSTALLROOT/lib64/cmake/VecCore")|' $INSTALLROOT/lib64/cmake/VecGeom/VecGeomConfig.cmake
