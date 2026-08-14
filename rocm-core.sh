package: rocm-core
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - Python
  - py-prettytable
  - py-PyYAML
  - gcc
---
export ROCM_CMAKE_EXTRA_ARGS='-DROCM_VERSION="%(version)s.0"'
#!include <rocm-systems-build.sh>
