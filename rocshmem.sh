package: rocshmem
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
  - rocm-cmake
requires:
  - gcc
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-hip
  - openmpi
  - rocm-comgr
---
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT" -DROCM_PATH=$ROCM_LLVM_ROOT -DUSE_EXTERNAL_MPI=ON -DBUILD_TESTING=OFF -DCMAKE_CXX_FLAGS="-I$ROCM_CORE_ROOT/include --rocm-device-lib-path=${ROCM_LLVM_ROOT}/amdgcn/bitcode" -DEXPLICIT_ROCM_VERSION=7.14.0'
#!include <rocm-systems-build.sh>
