package: cepgen
version: 1.2.5
sources:
 - https://github.com/cepgen/cepgen/archive/refs/tags/%(version)s.tar.gz
build_requires:
 - CMake
 - ninja
requires:
 - gcc
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

sed -i -e 's|add_subdirectory(BoostWrapper)||' "$BUILDDIR/CepGenAddOns/CMakeLists.txt"

# Export package roots for cmake discovery
export GSL_DIR="${GSL_ROOT}"
export OPENBLAS_DIR="${OPENBLAS_ROOT}"
export HEPMC_DIR="${HEPMC_ROOT}"
export HEPMC3_DIR="${HEPMC3_ROOT}"
export LHAPDF_PATH="${LHAPDF_ROOT}"
export PYTHIA6_DIR="${PYTHIA6_ROOT}"
export ROOTSYS="${ROOT_ROOT}"

CMAKE_ARGS=(
    -G Ninja
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DBoost_NO_SYSTEM_PATHS=ON
    -DCMAKE_PREFIX_PATH="${BZ2LIB_ROOT};${ZLIB_ROOT};${XZ_ROOT}"
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v}
ninja -C "$BUILDDIR/build" ${JOBS:+-j"$JOBS"} ${VERBOSE:+-v} install

# Remove unversioned addon libraries
rm -f "$INSTALLROOT/lib/libCepGen"-[A-Z]*-"%(version)s.so"
