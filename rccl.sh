package: rccl
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - amdsmi
  - rocm-hip
  - rocminfo
  - rocprofiler-register
  - rocm-smi-lib
  - roctracer
  - hipify
  - rocm-comgr
  - Python
---
export ROCM_PRE_BUILD_HOOK='export ROCM_PATH=${ROCM_LLVM_ROOT}; export CC=${ROCM_LLVM_ROOT}/bin/amdclang; export CXX=${ROCM_LLVM_ROOT}/bin/amdclang++'
export ROCM_CMAKE_EXTRA_ARGS='-DBUILD_TESTS=OFF -DROCM_PATH=${ROCM_HIP_ROOT} -DROCM_CORE_PATH=${ROCM_CORE_ROOT} -DEXPLICIT_ROCM_VERSION="7.14.0" -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102" -DCMAKE_CXX_FLAGS="--hip-device-lib-path=${ROCM_LLVM_ROOT}/amdgcn/bitcode -I${ROCM_CORE_ROOT}/include -include __clang_hip_runtime_wrapper.h -I${ROCTRACER_ROOT}/include" -DCMAKE_EXE_LINKER_FLAGS="-L${ROCM_HIP_ROOT}/lib -L${ROCTRACER_ROOT}/lib64 -L${ROCM_CORE_ROOT}/lib64" -DCMAKE_SHARED_LINKER_FLAGS="-L${ROCM_HIP_ROOT}/lib -L${ROCTRACER_ROOT}/lib64 -L${ROCM_CORE_ROOT}/lib64" -DROCM_VERSION=71300'
#!include <rocm-systems-build.sh>
