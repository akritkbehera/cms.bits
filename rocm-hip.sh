package: rocm-hip
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
  - py-CppHeaderParser
requires:
  - rocm-llvm
  - rocm-core
  - rocr-runtime
  - rocprofiler-register
  - numactl
  - Python
  - rocm-comgr
  - gcc
env:
  HIP_PATH: "$ROCM_HIP_ROOT"
  HIP_CLANG_PATH: "$ROCM_LLVM_ROOT/lib/llvm/bin"
  HIP_PLATFORM: "amd"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"
SRC="$BUILDDIR/rocm-systems"

cmake \
  -S "$SRC/projects/clr" \
  -B "$BUILDDIR/build-hip" \
  -DHIP_COMMON_DIR="$SRC/projects/hip" \
  -DHIP_PLATFORM=amd \
  -DCLR_BUILD_HIP=ON \
  -DCLR_BUILD_OCL=OFF \
  -DHIP_INSTALLS_HIPCC=ON \
  -DHIPCC_BIN_DIR=${ROCM_LLVM_ROOT}/bin \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="$ROCM_LLVM_ROOT;$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT" \
  -DCMAKE_C_COMPILER=${ROCM_LLVM_ROOT}/bin/amdclang \
  -DCMAKE_CXX_COMPILER=${ROCM_LLVM_ROOT}/bin/amdclang++ \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DHSA_PATH=${ROCR_RUNTIME_ROOT} \
  -DROCM_PATH=${ROCM_LLVM_ROOT} \
  -DDEVICE_LIB_PATH=${ROCM_LLVM_ROOT}/amdgcn/bitcode \
  -DLLVM_DIR=${ROCM_LLVM_ROOT}/lib/llvm/lib/cmake/llvm

make -C "$BUILDDIR/build-hip" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build-hip" install VERBOSE=1
