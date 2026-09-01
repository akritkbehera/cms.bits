package: rocm-smi-lib
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-sources
requires:
  - gcc
  - rocm-core
  - rocr-runtime
---
# pkg_check_modules(libdrm) relies on system libdrm (as in cmsdist's build OS);
# bits' sandboxed env does not search the system pkgconfig dir.
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
export ROCM_CMAKE_EXTRA_ARGS='-DBUILD_TESTING=OFF'
#!include <rocm-systems-build.sh>
