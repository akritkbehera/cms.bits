package: rccl
version: "7.2.4"
sources:
  - https://github.com/ROCm/rccl/archive/refs/tags/rocm-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
  - rocm-cmake
requires:
  - gcc
  - rocm-hip
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - amdsmi
  - rocminfo
  - rocprofiler-register
  - rocm-smi-lib
  - roctracer
  - hipify
  - Python
---
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"
export ROCM_PATH=${ROCM_LLVM_ROOT}
export CC=${ROCM_LLVM_ROOT}/bin/amdclang
export CXX=${ROCM_LLVM_ROOT}/bin/amdclang++

tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"

CMAKE_ARGS=(
  -S "$BUILDDIR"
  -B "$BUILDDIR/build"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT;$HIPIFY_ROOT;$ROCTRACER_ROOT"
  -DBUILD_TESTS=OFF
  -DROCM_PATH=${ROCM_HIP_ROOT}
  -DROCM_CORE_PATH=${ROCM_CORE_ROOT}
  -DEXPLICIT_ROCM_VERSION="%(version)s"
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102"
  -DCMAKE_CXX_FLAGS="--rocm-device-lib-path=${ROCM_LLVM_ROOT}/amdgcn/bitcode -I${ROCM_CORE_ROOT}/include -include __clang_hip_runtime_wrapper.h -I${ROCTRACER_ROOT}/include"
  -DCMAKE_EXE_LINKER_FLAGS="-L${ROCM_HIP_ROOT}/lib -L${ROCTRACER_ROOT}/lib64"
  -DCMAKE_SHARED_LINKER_FLAGS="-L${ROCM_HIP_ROOT}/lib -L${ROCTRACER_ROOT}/lib64"
)
cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
