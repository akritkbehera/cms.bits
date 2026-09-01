package: rocminfo
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-sources
requires:
  - gcc
  - rocm-core
  - rocr-runtime
---
#!include <rocm-systems-build.sh>
