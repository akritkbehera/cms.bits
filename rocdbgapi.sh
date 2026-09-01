package: rocdbgapi
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - rocm-sources
requires:
  - gcc
  - rocr-runtime
  - rocm-core
  - rocm-comgr
---
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_CXX_FLAGS="-Wno-sfinae-incomplete"'
#!include <rocm-systems-build.sh>
