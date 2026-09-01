package: origami
version: "7.14"
# Lives under rocm-libraries/shared/, not projects/ (port of cmsdist rocm/origami.spec).
# Previously built implicitly inside hipblaslt/hipsparselt; now a package of its own.
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
---
export ROCM_LIBRARIES_DIR="shared"
export ROCM_CMAKE_EXTRA_ARGS='-DORIGAMI_BUILD_TESTING=OFF'
#!include <rocm-libraries-build.sh>
