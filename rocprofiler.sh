package: rocprofiler
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/rocm-rel-7.2/rocm-%(version)s&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
  - py-barectf
  - py-CppHeaderParser
  - rocm-cmake
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
# ROCm (rocm-systems monorepo) package. Recipe-only; needs full ROCm toolchain to build.
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

# Strip the perfetto submodule-checkout call (lines 1-7); the source is a tarball,
# not a git repo, so the in-cmake `git submodule update` fails (as in cmsdist).
sed -i '1,7d' "$BUILDDIR/rocm-systems/projects/rocprofiler/plugin/perfetto/CMakeLists.txt"

# No cmake option to disable the (unbuildable) tests; patch the flag off, as cmsdist does.
sed -i 's/^set(ROCPROFILER_BUILD_TESTS ON)/set(ROCPROFILER_BUILD_TESTS OFF)/' \
  "$BUILDDIR/rocm-systems/projects/rocprofiler/CMakeLists.txt"

cmake \
  -S "$BUILDDIR/rocm-systems/projects/rocprofiler" \
  -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102" \
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT" \
  -DCMAKE_C_FLAGS="-I${NUMACTL_ROOT}/include -I${ROCM_CORE_ROOT}/include" \
  -DCMAKE_CXX_FLAGS="-I${NUMACTL_ROOT}/include -I${ROCM_CORE_ROOT}/include" \
  -DCMAKE_SHARED_LINKER_FLAGS="-L${GCC_ROOT}/lib -L${NUMACTL_ROOT}/lib" \
  -DCMAKE_EXE_LINKER_FLAGS="-L${GCC_ROOT}/lib -L${NUMACTL_ROOT}/lib"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
