package: clhep
version: "2.4.7.2"
tag: fa41009631cf8ec83eb4f2de65af461f5818a52f
variables:
  github_user: cms-externals
  branch: cms/v%(version)s
sources:
  - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
requires:
  - gcc
build_requires:
  - CMake
  - ninja
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -G Ninja
    -S "$BUILDDIR/$PKGNAME-$PKGVERSION"
    -B "$BUILDDIR/build"
    -DCLHEP_BUILD_CXXSTD="-std=c++%(cms_cxx_std)s"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCLHEP_BUILD_STATIC_LIBS=OFF
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v}
ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v} install

rm -f "$INSTALLROOT/lib/libCLHEP-[A-Z]*-%(version)s.so"
