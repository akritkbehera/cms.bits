package: rocsolver
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - rocm-sources
requires:
  - gcc
  - rocm-hip
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - rocblas
  - rocsparse
  - fmt
  - rocprim
---
#!include <rocm-libraries-build.sh>
