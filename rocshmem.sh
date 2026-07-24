package: rocshmem
version: "7.2.4"
sources:
  - https://github.com/ROCm/rocSHMEM/archive/refs/tags/rocm-%(version)s.tar.gz
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
  - openmpi
---
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
CMAKE_ARGS=(
  -S "$BUILDDIR" -B "$BUILDDIR/build"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang"
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang++"
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT"
  -DROCM_PATH="$ROCM_LLVM_ROOT"
  -DUSE_EXTERNAL_MPI=ON
  -DBUILD_TESTING=OFF
  -DBUILD_CLIENTS_TESTS=off
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102"
  -DCMAKE_CXX_FLAGS="-I$ROCM_CORE_ROOT/include --rocm-device-lib-path=${ROCM_LLVM_ROOT}/amdgcn/bitcode"
)
cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
