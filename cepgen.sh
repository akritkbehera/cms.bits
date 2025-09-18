package: cepgen
version: 1.2.5
sources:
 - https://github.com/cepgen/cepgen/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - CMake
 - ninja
requires:
 - GSL
 - OpenBLAS
 - hepmc
 - hepmc3
 - lhapdf
 - pythia6
 - ROOT
 - bz2lib
 - zlib
 - xz
 - Python
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sed -i -e 's|add_subdirectory(BoostWrapper)||' CepGenAddOns/CMakeLists.txt
rm -rf ../build; mkdir ../build; cd ../build
export GSL_DIR=${GSL_ROOT}
export OPENBLAS_DIR=${OPENBLAS_ROOT}
export HEPMC_DIR=${HEPMC_ROOT}
export HEPMC3_DIR=${HEPMC3_ROOT}
export LHAPDF_PATH=${LHAPDF_ROOT}
export PYTHIA6_DIR=${PYTHIA6_ROOT}
export ROOTSYS=${ROOT_ROOT}

cmake $BUILDDIR -G Ninja \
  -DCMAKE_INSTALL_PREFIX:PATH="%i" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBoost_NO_SYSTEM_PATHS=ON \
  -DCMAKE_PREFIX_PATH="${BZ2LIB_ROOT};${ZLIB_ROOT};${XZ_ROOT}"

ninja -v ${JOBS:+-j$JOBS}
ninja -v ${JOBS:+-j$JOBS} install

so=$( [ "$(uname)" = "Darwin" ] && echo dylib || echo so )
rm -f "$INSTALLROOT/lib/libCepGen"-[A-Z]*-"$PKGVERSION.$so"
