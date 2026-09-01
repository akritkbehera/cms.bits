package: hipsolver
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
  - rocsolver
---
#!include <rocm-libraries-build.sh>
