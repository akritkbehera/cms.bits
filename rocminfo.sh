package: rocminfo
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/rocm-rel-7.2/rocm-%(version)s&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - rocm-core
  - rocr-runtime
---
# ROCm (rocm-systems monorepo) package. Recipe-only; needs full ROCm toolchain to build.
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"
cmake \
  -S "$BUILDDIR/rocm-systems/projects/rocminfo" \
  -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
