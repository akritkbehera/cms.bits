package: hipfile
version: "7.14"
build_requires:
 - CMake
 - rocm-sources
requires:
 - gcc
 - rocm-hip
 - rocm-core
 - rocr-runtime
 - rocm-comgr
---
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_INSTALL_LIBDIR=lib -DROCM_VERSION="%(version)s.0"'
#!include <rocm-systems-build.sh>
