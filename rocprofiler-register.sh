package: rocprofiler-register
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - fmt
---
export ROCM_PRE_BUILD_HOOK='
sed -i -e "s|add_subdirectory(external)|find_package(fmt REQUIRED)\nadd_subdirectory(external)|" "$BUILDDIR/rocm-systems/projects/rocprofiler-register/CMakeLists.txt"
sed -i -e "s|CMAKE_CXX_STANDARD  *17|CMAKE_CXX_STANDARD %(cms_cxx_std)s|" "$BUILDDIR/rocm-systems/projects/rocprofiler-register/cmake/rocprofiler_register_options.cmake"
'
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_CXX_STANDARD=%(cms_cxx_std)s -DCMAKE_VERBOSE_MAKEFILE=TRUE -DROCPROFILER_REGISTER_BUILD_FMT=OFF -DCMAKE_PREFIX_PATH="${FMT_ROOT}"'
#!include <rocm-systems-build.sh>
