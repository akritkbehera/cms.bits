package: rocminfo
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - rocm-core
  - rocr-runtime
---
#!include <rocm-systems-build.sh>
