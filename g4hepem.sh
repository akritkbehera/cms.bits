package: g4hepem
version: "20251114"
variables:
  tag:         "%(version)s"
  branch:      master
  github_user: mnovak42
sources:
  - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s.%(version)s&output=/%(package)s.%(version)s-%(tag)s.tgz
build_requires:
  - CMake
  - gmake
requires:
  - geant4
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

grep -q 'BUILD_SHARED_LIBS ON' "$BUILDDIR/CMakeLists.txt" && \
    sed -i -e 's|BUILD_SHARED_LIBS ON|BUILD_SHARED_LIBS OFF|' "$BUILDDIR/CMakeLists.txt"
grep -q 'BUILD_STATIC_LIBS OFF' "$BUILDDIR/CMakeLists.txt" && \
    sed -i -e 's|BUILD_STATIC_LIBS OFF|BUILD_STATIC_LIBS ON|' "$BUILDDIR/CMakeLists.txt"

mkdir -p "$BUILDDIR/build"
cd "$BUILDDIR/build"

cmake "$BUILDDIR" \
  -DCMAKE_CXX_COMPILER="g++" \
  -DCMAKE_AR="${GCC_ROOT}/bin/gcc-ar" \
  -DCMAKE_RANLIB="${GCC_ROOT}/bin/gcc-ranlib" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_STATIC_LIBS=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_PREFIX_PATH="${GEANT4_ROOT}"

make ${JOBS:+-j$JOBS} VERBOSE=1
make install

mkdir -p "$BUILDDIR/tmp_archive"
pushd "$BUILDDIR/tmp_archive"
  find "$INSTALLROOT/lib64" -name "*.a" -exec ${GCC_ROOT}/bin/gcc-ar x {} \;
  ${GCC_ROOT}/bin/gcc-ar rcs "$INSTALLROOT/lib64/libg4hepem-static.a" *.o
popd
rm -rf "$BUILDDIR/tmp_archive"
