package: rocfft
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
  - hiprand
---
export ROCM_CMAKE_EXTRA_ARGS='-DROCFFT_BUILD_OFFLINE_TUNER=OFF -DROCFFT_KERNEL_CACHE_ENABLE=OFF'
#!include <rocm-libraries-build.sh>
