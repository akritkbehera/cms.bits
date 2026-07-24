package: rocm-comgr
version: "7.2.4"
sources:
  - https://github.com/ROCm/llvm-project/archive/refs/tags/rocm-%(version)s.tar.gz
patches:
  - 0001-comgr-link-with-static-llvm.patch
build_requires:
  - CMake
  - ninja
requires:
  - rocm-llvm
  - rocm-core
  - zlib
  - zstd
  - libxml2
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

sed -i "s/TARGET clangFrontendTool/true/" "$BUILDDIR/amd/comgr/CMakeLists.txt"
sed -i -e 's|^\s*TargetParser\s*$| TargetParser Coverage FrontendDriver FrontendHLSL LTO Option Symbolize WindowsDriver|' "$BUILDDIR/amd/comgr/CMakeLists.txt"

cmake -G "Unix Makefiles" \
  -S "$BUILDDIR/amd/comgr" \
  -B "$BUILDDIR/build-comgr" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_C_COMPILER=$ROCM_LLVM_ROOT/lib/llvm/bin/clang \
  -DCMAKE_CXX_COMPILER=$ROCM_LLVM_ROOT/lib/llvm/bin/clang++ \
  -DCMAKE_BUILD_TYPE=Release \
  -DCOMGR_BUILD_SHARED_LIBS=ON \
  -DCMAKE_PREFIX_PATH="$ROCM_LLVM_ROOT;$ZLIB_ROOT;$ZSTD_ROOT;$LIBXML2_ROOT"
make -C "$BUILDDIR/build-comgr" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build-comgr" install VERBOSE=1
