package: hipfft
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-libraries.git?obj=develop/rocm-%(version)s&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
build_requires:
  - CMake
  - gmake
  - rocm-cmake
requires:
  - gcc
  - rocm-hip
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - rocfft
---
# ROCm library package: builds rocm-libraries/projects/<pkg> with amdclang (port of
# cmsdist rocm-libraries-build). Will not build without a full ROCm toolchain + AMD GPU.
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"

tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

CMAKE_ARGS=(
  -B "$BUILDDIR/build"
  -S "$BUILDDIR/rocm-libraries/projects/hipfft"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang"
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang++"
  -DCMAKE_PREFIX_PATH="$ROCM_HIP_ROOT;$ROCM_CORE_ROOT;$ROCM_LLVM_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT"
  -DBUILD_CLIENTS_TESTS=off
  -DHIP_ROOT=$ROCM_HIP_ROOT
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102"
)
cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
