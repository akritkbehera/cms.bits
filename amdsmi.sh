package: amdsmi
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-sources
requires:
  - gcc
  - rocm-core
  - Python
  - libnl
  - libmnl
---
# amdsmi pkg_check_modules(libdrm) relies on system libdrm (as in cmsdist's build OS);
# bits' sandboxed env does not search the system pkgconfig dir, so add it explicitly.
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
export ROCM_CMAKE_EXTRA_ARGS='-DBUILD_TESTING=OFF -DCMAKE_SHARED_LINKER_FLAGS="-L$LIBNL_ROOT/lib -L$LIBMNL_ROOT/lib" -DCMAKE_EXE_LINKER_FLAGS="-L$LIBNL_ROOT/lib -L$LIBMNL_ROOT/lib"'
#!include <rocm-systems-build.sh>
