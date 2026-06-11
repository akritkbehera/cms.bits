package: hepmc3
version: "3.3.1"
sources:
 - https://gitlab.cern.ch/hepmc/HepMC3/-/archive/%(version)s/HepMC3-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - "gcc:(?gcc)"
  - zlib
  - bz2lib
  - xz
  - zstd
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build && mkdir ../build && cd ../build

cmake $BUILDDIR \
  -DCMAKE_CXX_STANDARD=$CXXSTD \
  -DHEPMC3_CXX_STANDARD=$CXXSTD \
  -DHEPMC3_ENABLE_ROOTIO=OFF \
  -DHEPMC3_ENABLE_TEST=OFF \
  -DHEPMC3_TEST_THREADS=OFF \
  -DHEPMC3_TEST_ZLIB=ON \
  -DHEPMC3_TEST_LZMA=ON \
  -DHEPMC3_TEST_BZIP2=ON \
  -DHEPMC3_TEST_ZSTD=ON \
  -DHEPMC3_ENABLE_PYTHON=OFF \
  -DHEPMC3_BUILD_STATIC_LIBS=OFF \
  -DHEPMC3_BUILD_DOCS=OFF \
  -DHEPMC3_INSTALL_INTERFACES=ON \
  -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT \
  -DCMAKE_PREFIX_PATH="${ZLIB_ROOT};${BZ2LIB_ROOT};${XZ_ROOT};${ZSTD_ROOT}"

make ${JOBS:+-j $JOBS}
make install
