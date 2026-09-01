package: roctracer
version: "7.14"
build_requires:
  - CMake
  - gmake
  - py-CppHeaderParser
  - rocm-sources
requires:
  - gcc
  - rocr-runtime
  - rocm-hip
  - rocm-comgr
---
export ROCM_PRE_BUILD_HOOK='sed -i "s/add_subdirectory(test)/# add_subdirectory(test)/" "$BUILDDIR/rocm-systems/projects/roctracer/CMakeLists.txt"'
export ROCM_CMAKE_EXTRA_ARGS='-DBUILD_TESTS=OFF'
#!include <rocm-systems-build.sh>
