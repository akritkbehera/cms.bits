package: rocm-cmake
version: "7.14"
sources:
  - https://github.com/ROCm/rocm-cmake/archive/refs/tags/therock-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
cmake \
  -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DROCM_VERSION=%(version)s \
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT"
cmake --build "$BUILDDIR/build" ${JOBS:+--parallel $JOBS} --verbose
cmake --install "$BUILDDIR/build" --verbose
