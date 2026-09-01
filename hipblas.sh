package: hipblas
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - boost
  - rocm-sources
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
