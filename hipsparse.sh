package: hipsparse
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
  - rocprim
  - rocsparse
---
#!include <rocm-libraries-build.sh>
