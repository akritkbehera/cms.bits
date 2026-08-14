package: rocr-runtime
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - rocm-core
  - zlib
  - libxml2
  - rocprofiler-register
  - numactl
  - rocm-llvm
  - gcc
---
# libhsakmt pkg_check_modules(libdrm) relies on system libdrm (as in cmsdist's
# build OS); bits' sandboxed env does not search the system pkgconfig dir.
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
export ROCM_PRE_BUILD_HOOK='export ROCM_PATH=$ROCM_LLVM_ROOT; export ROCM_DEVICE_LIB_PATH=$ROCM_LLVM_ROOT/amdgcn/bitcode'
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_CXX_COMPILER=$ROCM_LLVM_ROOT/lib/llvm/bin/clang++ -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ZLIB_ROOT;$LIBXML2_ROOT;$ROCPROFILER_REGISTER_ROOT;$NUMACTL_ROOT;$ROCM_LLVM_ROOT" -DBUILD_SHARED_LIBS=ON -DCMAKE_C_FLAGS="-I${NUMACTL_ROOT}/include" -DCMAKE_CXX_FLAGS="-I${NUMACTL_ROOT}/include --rocm-path=$ROCM_LLVM_ROOT"'
#!include <rocm-systems-build.sh>
