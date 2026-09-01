package: rocm-hip
version: "7.14"
patches:
  - rocm-systems-issue10529.patch
build_requires:
  - CMake
  - gmake
  - py-CppHeaderParser
  - rocm-sources
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
# HIP (CLR) from the rocm-systems monorepo; the tarball comes from the shared
# rocm-sources package rather than a per-package clone.
tar -xzf "$ROCM_SOURCES_ROOT/rocm_systems.tar.gz" -C "$BUILDDIR"
SRC="$BUILDDIR/rocm-systems"

export HIP_CLANG_PATH=${ROCM_LLVM_ROOT}/lib/llvm/bin

HIPRTC_CMAKE="$SRC/projects/clr/hipamd/src/hiprtc/CMakeLists.txt"
grep -qF -- '-nogpulib --hip-version=' "$HIPRTC_CMAKE"
sed -i 's|-nogpulib --hip-version=|-nogpulib -nogpuinc --hip-version=|' "$HIPRTC_CMAKE"

# Prevent a deadlock between hipEventSynchronize and hipMallocAsync (cmsdist issue #10529).
patch -p3 -d "$SRC/projects/clr" < "$SOURCEDIR/rocm-systems-issue10529.patch"

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
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_PREFIX_PATH="$ROCM_LLVM_ROOT;$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$ROCPROFILER_REGISTER_ROOT;$NUMACTL_ROOT;$PYTHON_ROOT" \
  -DCMAKE_C_COMPILER=${ROCM_LLVM_ROOT}/bin/amdclang \
  -DCMAKE_CXX_COMPILER=${ROCM_LLVM_ROOT}/bin/amdclang++ \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DHSA_PATH=${ROCR_RUNTIME_ROOT} \
  -DROCM_PATH=${ROCM_LLVM_ROOT} \
  -DDEVICE_LIB_PATH=${ROCM_LLVM_ROOT}/amdgcn/bitcode \
  -DLLVM_DIR=${ROCM_LLVM_ROOT}/lib/llvm/lib/cmake/llvm

make -C "$BUILDDIR/build-hip" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build-hip" install VERBOSE=1
