package: vecgeom
version: "1.2.11"
variables:
 vecgeom_backend: Scalar
 tag: 47dd602df7074fcc78036e93cd639ae6270207fd
sources: 
- git+https://gitlab.cern.ch/vecgeom/vecgeom.git?obj=master/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
patches:
- vecgeom-fix-vector.patch
build_requires:
- CMake 
- gmake
requires:
- gcc
- xerces-c
- compilation_flags
- compilation_flags_lto
- compilation_flags_pgo
- microarch-flag
env:
  USE_VECGEOM: "1"
---
eval "$setup_pgo"
setup_pgo_flags "$BUILDDIR" "$PKGNAME/$PKGHASH"
export BUILD_FLAGS="-fPIC $arch_build_flags $lto_build_flags $pgo_build_flags"

tar -xzf "$SOURCEDIR/$SOURCE0" \
    --strip-components=1 \
    -C "$BUILDDIR" 

patch -p1 < $SOURCEDIR/$PATCH0

if [ "$(uname -m)" = "x86_64" ]; then
  if [[ "%(vecgeom_backend)s" == "Vc" ]]; then
    SEL_ARCH="$(echo "$selected_microarch" | sed 's|^-m||')"
    VECGEOM_VECTOR_INST="$(grep ' set(VECGEOM_ISAS ' CMakeLists.txt | tr ' ' '\n' | grep -E "^${SEL_ARCH}$")"
  fi
fi

rm -rf $BUILDROOT/build && mkdir $BUILDROOT/build && cd $BUILDROOT/build

make_args=(
  -DVecGeom_GIT_DESCRIBE="$PKG_VERSION"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DBUILD_TESTING=OFF
  -DVecGeom_VERSION="$PKG_VERSION"
  -DCMAKE_CXX_STANDARD:STRING="$CXXSTD"
  -DCMAKE_AR="$GCC_ROOT/bin/gcc-ar"
  -DCMAKE_RANLIB="$GCC_ROOT/bin/gcc-ranlib"
  -DCMAKE_BUILD_TYPE="$LLVM_BUILD_TYPE"
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG $BUILD_FLAGS"
  -DCMAKE_VERBOSE_MAKEFILE=TRUE
  -DBUILD_SHARED_LIBS=OFF
  -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="$BUILD_FLAGS"
  -DCMAKE_STATIC_LIBRARY_C_FLAGS="$BUILD_FLAGS"  
  -DCMAKE_CXX_FLAGS="$BUILD_FLAGS"
  -DCMAKE_C_FLAGS="$BUILD_FLAGS"
  -DVECGEOM_NO_SPECIALIZATION=ON
  -DVECGEOM_BUILTIN_VECCORE=ON
  -DVECGEOM_BACKEND="%(vecgeom_backend)s"
  -DVECGEOM_GEANT4=OFF
  -DVECGEOM_ROOT=OFF
  -DCMAKE_PREFIX_PATH="$XERCES_C_ROOT"
)

if [[ "%(vecgeom_backend)s" == "Vc" ]]; then
  make_args+=(
    -DVECGEOM_VECTOR="${VECGEOM_VECTOR_INST}"
  )
fi

cmake "${make_args[@]}" $BUILDDIR
make ${jobs:+-j$jobs}
make install verbose=1

sed -i -e 's|set(VecCore_DIR .*|set(VecCore_DIR "$INSTALLROOT/lib64/cmake/VecCore")|' $INSTALLROOT/lib64/cmake/VecGeom/VecGeomConfig.cmake
