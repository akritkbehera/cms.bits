package: stinkytofu
version: "7.14"
# Lives under rocm-libraries/shared/, not projects/ (port of cmsdist rocm/stinkytofu.spec).
# Previously built implicitly inside hipblaslt; now a package of its own, which is also
# where the gcc14 <limits.h> fix lives (it used to be patched tree-wide via
# rocm-libraries.patch).
patches:
  - rocm-stinkytofu-gcc14.patch
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
  - Python
prepend_path:
  PYTHON3PATH: "%(root_dir)s/lib/python3.12/dist-packages"
---
export ROCM_LIBRARIES_DIR="shared"
export ROCM_PRE_BUILD_HOOK='patch -p1 -d "$BUILDDIR/rocm-libraries/shared/stinkytofu" < "$SOURCEDIR/rocm-stinkytofu-gcc14.patch"'
export ROCM_CMAKE_EXTRA_ARGS='-DSTINKYTOFU_BUILD_TESTS=OFF -DSTINKYTOFU_CODE_COVERAGE=OFF'
#!include <rocm-libraries-build.sh>
