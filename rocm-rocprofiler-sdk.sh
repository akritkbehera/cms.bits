package: rocm-rocprofiler-sdk
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/rocm-rel-7.2/rocm-%(version)s&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
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
# ROCm (rocm-systems monorepo) package. Recipe-only; needs full ROCm toolchain to build.
export CC=${ROCM_LLVM_ROOT}/bin/amdclang
export CXX=${ROCM_LLVM_ROOT}/bin/amdclang++
# system libdrm via pkg-config (as in cmsdist's build OS); bits' sandboxed env omits it.
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"

tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

# The packaging cmake calls cpack_add_component_group even with CPACK_ENABLED=OFF;
# pull in the CPack module so that command is defined (as cmsdist does).
sed -i '2i\include(CPack)' "$BUILDDIR/rocm-systems/projects/rocprofiler-sdk/CMakeLists.txt"

cmake \
  -S "$BUILDDIR/rocm-systems/projects/rocprofiler-sdk" \
  -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT;$ROCPROFILER_ROOT;$ROCPROFILER_REGISTER_ROOT;$AQLPROFILE_ROOT;$FMT_ROOT;$GLOG_ROOT;$SQLITE_ROOT;$PY_PYBIND11_ROOT;$GCC_ROOT" \
  -DROCPROFILER_BUILD_TESTS=OFF \
  -DROCPROFILER_BUILD_FMT=OFF \
  -DROCPROFILER_BUILD_GHC_FS=OFF \
  -DROCPROFILER_BUILD_GLOG=OFF \
  -DROCPROFILER_BUILD_PYBIND11=OFF \
  -DROCPROFILER_BUILD_SQLITE3=OFF \
  -DCPACK_ENABLED=OFF \
  -DCMAKE_CXX_FLAGS="-include fstream -include array -include memory -include unistd.h -include cstdint -I$GCC_ROOT/include -I$ROCM_LLVM_ROOT/lib/llvm/include -I$ROCM_LLVM_ROOT/include -I$ROCM_COMGR_ROOT/include" \
  -DCMAKE_SHARED_LINKER_FLAGS="-L$GCC_ROOT/lib" \
  -DCMAKE_EXE_LINKER_FLAGS="-L$GCC_ROOT/lib" \
  -DCMAKE_MODULE_LINKER_FLAGS="-L$GCC_ROOT/lib"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
