package: hipblas-common
version: "7.2.4"
sources:
 - git+https://github.com/ROCm/rocm-libraries.git?obj=develop&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
patches:
  - rocm-libraries.patch
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
---
#!include <rocm-libraries-build.sh>
