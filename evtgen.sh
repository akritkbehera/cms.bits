package: evtgen
version: 2.0.0
variables:
  tag: bcb7af4d35bf66a01c08fa4f8fffb623b7e24c59
  branch: cms/%(version)s
  github_user: cms-externals
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
 - CMake
requires:
 - gcc
 - hepmc
 - pythia8
 - tauolapp
 - photospp
patches:
 - evtgen-2.0.0.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"

cmake_args=(
  -S "$BUILDDIR"
  -B "$BUILDDIR/build"
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
  -DEVTGEN_HEPMC3:BOOL=OFF
  -DHEPMC2_ROOT_DIR:PATH="$HEPMC_ROOT"
  -DEVTGEN_PYTHIA:BOOL=ON
  -DPYTHIA8_ROOT_DIR:PATH="$PYTHIA8_ROOT"
  -DEVTGEN_PHOTOS:BOOL=ON
  -DPHOTOSPP_ROOT_DIR:PATH="$PHOTOSPP_ROOT"
  -DEVTGEN_TAUOLA:BOOL=ON
  -DTAUOLAPP_ROOT_DIR:PATH="$TAUOLAPP_ROOT"
)

cmake "${cmake_args[@]}"

# spec builds serially (plain make, no %makeprocesses)
make -C "$BUILDDIR/build"
make -C "$BUILDDIR/build" install

mkdir -p "$INSTALLROOT/lib"
find "$INSTALLROOT/lib64" -name "*.*" -exec mv {} "$INSTALLROOT/lib" \;
rm -rf "$INSTALLROOT/lib64"
ls "$INSTALLROOT/lib"
