package: hipblas
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-libraries.git?obj=release/therock-%(version)s/HEAD&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
patches:
  - rocm-libraries.patch
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - boost
requires:
  - gcc
  - rocm-hip
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - roctracer
  - hipblas-common
  - Python
  - rocblas
  - rocsparse
  - rocsolver
---
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_CXX_FLAGS="$ROCM_DEVICE_LIB_FLAG -I$BOOST_ROOT/include"'
#!include <rocm-libraries-build.sh>
