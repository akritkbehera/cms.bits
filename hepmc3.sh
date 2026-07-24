package: hepmc3
version: "3.3.1"
sources:
 - https://gitlab.cern.ch/hepmc/HepMC3/-/archive/%(version)s/HepMC3-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - zlib
  - bz2lib
  - xz
  - zstd
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s
    -DHEPMC3_CXX_STANDARD=%(cms_cxx_std)s
    -DHEPMC3_ENABLE_ROOTIO="OFF"
    -DHEPMC3_ENABLE_TEST="ON"
    -DHEPMC3_TEST_THREADS="ON"
    -DHEPMC3_TEST_HEPMC2="OFF"
    -DHEPMC3_TEST_VALGRIND="OFF"
    -DHEPMC3_TEST_ZLIB="ON"
    -DHEPMC3_TEST_LZMA="ON"
    -DHEPMC3_TEST_BZIP2="ON"
    -DHEPMC3_TEST_ZSTD="ON"
    -DHEPMC3_ENABLE_PYTHON="OFF"
    -DHEPMC3_BUILD_STATIC_LIBS="OFF"
    -DHEPMC3_BUILD_DOCS="OFF"
    -DHEPMC3_INSTALL_INTERFACES="ON"
    -DCMAKE_PREFIX_PATH="${GCC_ROOT};${ZLIB_ROOT};${BZ2LIB_ROOT};${XZ_ROOT};${ZSTD_ROOT}"
    -L
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install
