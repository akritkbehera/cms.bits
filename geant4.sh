package: geant4
version: "11.2.2"
tag: e1c646ceca4bd407f6d10c0728e11b69dcffdcc0
variables:
 github_user: cms-externals
 branch: cms/v%(version)s
sources:
-  git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag_basename)s&export=%(package)s.%(version)s&output=/%(package)s.%(version)s-%(tag_basename)s.tgz
build_requires:
- CMake 
- gmake 
requires:
- clhep
- expat
- xerces-c
- zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

soext="so"
if [[ "$(uname -s)" == "Darwin" ]]; then
    soext="dylib"
fi

rm -rf ../build
mkdir ../build
cd ../build

cmake_args=(
  -DCMAKE_CXX_COMPILER="g++"
  -DCMAKE_CXX_FLAGS="${BUILD_FLAGS}"
  -DCMAKE_AR="$(which gcc-ar)"
  -DCMAKE_RANLIB="$(which gcc-ranlib)"
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
  -DCMAKE_CXX_STANDARD:STRING="$CXXSTD"
  -DCMAKE_BUILD_TYPE="$LLVM_BUILD_TYPE"
  -DGEANT4_USE_GDML=ON
  -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"
  -DGEANT4_ENABLE_TESTING=OFF
  -DGEANT4_BUILD_VERBOSE_CODE=OFF
  -DGEANT4_BUILD_BUILTIN_BACKTRACE=OFF
  -DBUILD_SHARED_LIBS=ON
  -DBUILD_STATIC_LIBS=ON
  -DGEANT4_INSTALL_EXAMPLES=OFF
  -DGEANT4_USE_SYSTEM_CLHEP=ON
  -DGEANT4_USE_SYSTEM_EXPAT=ON
  -DGEANT4_USE_SYSTEM_ZLIB=ON
  -DGEANT4_BUILD_MULTITHREADED=ON
  -DXercesC_INCLUDE_DIR=$XERCES_C_ROOT/include \
  -DXercesC_LIBRARY=$XERCES_C_ROOT/lib/libxerces-c.so \
  -DXercesC_VERSION=3.1.3
)

if [[ -n "$enable_vecgeom" ]]; then
  cmake_args+=(
    -DGEANT4_USE_USOLIDS="all"
    -DVecGeom_DIR="${VECGEOM_ROOT}/lib64/cmake/VecGeom"
    -DVecCore_DIR="${VECGEOM_ROOT}/lib64/cmake/VecCore"
  )
fi

cmake "${cmake_args[@]}" ../$PKGNAME

make ${JOBS:+-j$JOBS} 
make install

mkdir -p $INSTALLROOT/lib64/archive
cp $INSTALLROOT/lib64/archive
find $INSTALLROOT/lib64 -name "*.a" -exec gcc-ar x {} \;
gcc-ar rcs libgeant4-static.a *.o
find . -name "*.o" -delete

if [[ -n "$PGO_BUILD_FLAGS" ]]; then
  sed -i -r -e 's| +(-fprofile-[^ ]+ )+||' "$INSTALLROOT/lib64/Geant4-*/Geant4Config.cmake" "$INSTALLROOT/bin/geant4-config"
fi


