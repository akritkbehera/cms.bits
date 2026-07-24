package: rocm-core
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/rocm-rel-7.2/rocm-%(version)s&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - Python
  - py-prettytable
  - py-PyYAML
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

cmake \
  -S "$BUILDDIR/rocm-systems/projects/rocm-core" \
  -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DROCM_VERSION=%(version)s

cmake --build "$BUILDDIR/build" ${JOBS:+--parallel $JOBS} --verbose
cmake --install "$BUILDDIR/build" --verbose
