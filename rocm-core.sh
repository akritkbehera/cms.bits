package: rocm-core
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-sources
requires:
  - Python
  - py-prettytable
  - py-PyYAML
  - gcc
---
export ROCM_CMAKE_EXTRA_ARGS='-DROCM_VERSION="%(version)s.0"'
#!include <rocm-systems-build.sh>
