package: rocprofiler
version: "7.14"
build_requires:
  - CMake
  - gmake
  - py-barectf
  - py-CppHeaderParser
  - rocm-cmake
  - rocm-sources
requires:
  - gcc
  - rocm-core
  - rocr-runtime
  - Python
  - aqlprofile
  - rocm-hip
  - numactl
  - libxml2
  - roctracer
  - py-lxml
  - py-PyYAML
  - rocm-comgr
---
# Strip the perfetto submodule-checkout call (lines 1-7); the source is a tarball,
# not a git repo, so the in-cmake `git submodule update` fails (as in cmsdist).
# No cmake option to disable the (unbuildable) tests/CI; patch the flags off, as cmsdist does.
export ROCM_PRE_BUILD_HOOK='
sed -i "1,7d" "$BUILDDIR/rocm-systems/projects/rocprofiler/plugin/perfetto/CMakeLists.txt"
sed -i "s/^set(ROCPROFILER_BUILD_TESTS ON)/set(ROCPROFILER_BUILD_TESTS OFF)/" "$BUILDDIR/rocm-systems/projects/rocprofiler/CMakeLists.txt"
sed -i "s/^set(ROCPROFILER_BUILD_CI ON)/set(ROCPROFILER_BUILD_CI OFF)/" "$BUILDDIR/rocm-systems/projects/rocprofiler/CMakeLists.txt"
'
export ROCM_CMAKE_EXTRA_ARGS='-DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102" -DCMAKE_CXX_FLAGS="-I${NUMACTL_ROOT}/include -I${ROCM_CORE_ROOT}/include" -DCMAKE_C_FLAGS="-I${NUMACTL_ROOT}/include -I${ROCM_CORE_ROOT}/include" -DCMAKE_SHARED_LINKER_FLAGS="-L${GCC_ROOT}/lib -L${NUMACTL_ROOT}/lib" -DCMAKE_EXE_LINKER_FLAGS="-L${GCC_ROOT}/lib -L${NUMACTL_ROOT}/lib"'
#!include <rocm-systems-build.sh>
