package: hipify
version: "7.14"
sources:
  - git+https://github.com/ROCm/HIPIFY.git?obj=amd-develop/therock-%(version)s&export=hipify&submodules=1&output=/hipify.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - rocm-llvm
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

CMAKE_ARGS=(
  -B "$BUILDDIR/build"
  -S "$BUILDDIR/hipify"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/lib/llvm/bin/clang"
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/lib/llvm/bin/clang++"
  -DLLVM_DIR="$ROCM_LLVM_ROOT/lib/llvm/lib/cmake/llvm"
  -DCMAKE_PREFIX_PATH="$ROCM_LLVM_ROOT/lib/llvm;$ROCM_CORE_ROOT"
)
cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
