package: rocprim
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-libraries.git?obj=release/therock-%(version)s/HEAD&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
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
