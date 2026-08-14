package: rocm-rocprofiler-sdk
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
  - rocm-cmake
requires:
  - gcc
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocprofiler
  - rocm-comgr
  - fmt
  - glog
  - sqlite
  - py-pybind11
  - aqlprofile
  - rocprofiler-register
---
# system libdrm via pkg-config (as in cmsdist's build OS); bits' sandboxed env omits it.
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
export ROCM_PROJECT="rocprofiler-sdk"
export ROCM_PRE_BUILD_HOOK='
sed -i "2i\include(CPack)" "$BUILDDIR/rocm-systems/projects/rocprofiler-sdk/CMakeLists.txt"
export CC=${ROCM_LLVM_ROOT}/bin/amdclang
export CXX=${ROCM_LLVM_ROOT}/bin/amdclang++
'
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT;$ROCPROFILER_ROOT;$ROCPROFILER_REGISTER_ROOT;$AQLPROFILE_ROOT;$FMT_ROOT;$GLOG_ROOT;$SQLITE_ROOT;$PY_PYBIND11_ROOT;$GCC_ROOT" -DROCPROFILER_BUILD_TESTS=OFF -DROCPROFILER_BUILD_FMT=OFF -DROCPROFILER_BUILD_GHC_FS=OFF -DROCPROFILER_BUILD_GLOG=OFF -DROCPROFILER_BUILD_PYBIND11=OFF -DROCPROFILER_BUILD_SQLITE3=OFF -DCPACK_ENABLED=OFF -DCMAKE_CXX_FLAGS="-include fstream -include array -include memory -include unistd.h -include cstdint -I$GCC_ROOT/include -I$ROCM_LLVM_ROOT/lib/llvm/include -I$ROCM_LLVM_ROOT/include -I$ROCM_COMGR_ROOT/include -I$SQLITE_ROOT/include" -DCMAKE_SHARED_LINKER_FLAGS="-L$GCC_ROOT/lib -L$SQLITE_ROOT/lib" -DCMAKE_EXE_LINKER_FLAGS="-L$GCC_ROOT/lib -L$SQLITE_ROOT/lib" -DCMAKE_MODULE_LINKER_FLAGS="-L$GCC_ROOT/lib"'
#!include <rocm-systems-build.sh>
