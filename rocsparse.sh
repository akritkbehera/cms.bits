package: rocsparse
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - rocm-sources
requires:
  - gcc
  - rocm-hip
  - roctracer
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - rocprim
  - rocblas
---
#!include <rocm-libraries-build.sh>
