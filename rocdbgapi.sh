package: rocdbgapi
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
  - rocm-cmake
requires:
  - gcc
  - rocr-runtime
  - rocm-core
  - rocm-comgr
---
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_CXX_FLAGS="-Wno-sfinae-incomplete"'
#!include <rocm-systems-build.sh>
