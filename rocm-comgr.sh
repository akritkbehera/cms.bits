package: rocm-comgr
version: "7.14"
sources:
  - https://github.com/ROCm/llvm-project/archive/refs/tags/therock-%(version)s.tar.gz
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

grep -q 'if(NOT CLANG_LINK_CLANG_DYLIB)' "$BUILDDIR/amd/comgr/CMakeLists.txt"
sed -i "s/if(NOT CLANG_LINK_CLANG_DYLIB)/if(TRUE)/" "$BUILDDIR/amd/comgr/CMakeLists.txt"
grep -q '^\s*TargetParser\s*$' "$BUILDDIR/amd/comgr/CMakeLists.txt"
sed -i -e 's|^\s*TargetParser\s*$| TargetParser Coverage FrontendDriver FrontendHLSL LTO Option Symbolize WindowsDriver|' "$BUILDDIR/amd/comgr/CMakeLists.txt"

cmake -G "Unix Makefiles" \
  -S "$BUILDDIR/amd/comgr" \
  -B "$BUILDDIR/build-comgr" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_C_COMPILER=$ROCM_LLVM_ROOT/lib/llvm/bin/clang \
  -DCMAKE_CXX_COMPILER=$ROCM_LLVM_ROOT/lib/llvm/bin/clang++ \
  -DCMAKE_BUILD_TYPE=Release \
  -DCOMGR_BUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCOMGR_STATIC_LLVM=ON \
  -DBUILD_TESTING=OFF \
  -DCMAKE_PREFIX_PATH="$ROCM_LLVM_ROOT;$ZLIB_ROOT;$ZSTD_ROOT;$LIBXML2_ROOT"

LLVMLIBS="-L$ROCM_LLVM_ROOT/lib/llvm/lib $($ROCM_LLVM_ROOT/lib/llvm/bin/llvm-config --link-static --libs)"
grep -q -E ' [^ ]*libLLVM\.so(\.[0-9]+)+git( |$)' "$BUILDDIR/build-comgr/CMakeFiles/amd_comgr.dir/link.txt"
sed -E -i \
  -e "s@[^ ]*libLLVM\.so(\.[0-9]+)+git@$LLVMLIBS@" \
  "$BUILDDIR/build-comgr/CMakeFiles/amd_comgr.dir/link.txt"

make -C "$BUILDDIR/build-comgr" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build-comgr" install VERBOSE=1
