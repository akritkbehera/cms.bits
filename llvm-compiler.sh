package: llvm-compiler
version: "21.1.4"
tag: "llvmorg-%(version)s"
source: https://github.com/llvm/llvm-project
---
# Self-contained LLVM compiler toolchain — no bits dependencies.
# Uses whatever cmake, ninja, and C++ compiler the system provides.
# External library deps (zlib, libxml2, zstd, libffi) are disabled so nothing
# outside the LLVM source tree is required at build or install time.
# The full runtime stack (libc++, libc++abi, libunwind, compiler-rt, lld) is
# built from source, making this package independent of any system GCC runtime.

rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

rm -rf "$BUILDROOT/build" && mkdir -p "$BUILDROOT/build" && cd "$BUILDROOT/build"

host_triple=$(cc -dumpmachine 2>/dev/null || gcc -dumpmachine)

cmake_args=(
  -G Ninja
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE=Release

  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld"
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;compiler-rt;openmp"

  -DLLVM_BUILD_LLVM_DYLIB=ON
  -DLLVM_LINK_LLVM_DYLIB=ON
  -DLLVM_LIBDIR_SUFFIX=64

  -DLLVM_ENABLE_EH=ON
  -DLLVM_ENABLE_RTTI=ON
  -DLLVM_ENABLE_PIC=ON

  -DLLVM_HOST_TRIPLE="$host_triple"
  -DLLVM_TARGETS_TO_BUILD="X86;PowerPC;AArch64;RISCV;NVPTX"

  -DLLVM_ENABLE_ZLIB=OFF
  -DLLVM_ENABLE_ZSTD=OFF
  -DLLVM_ENABLE_LIBXML2=OFF
  -DLLVM_ENABLE_FFI=OFF
  -DLLVM_ENABLE_LIBEDIT=OFF
  -DLLVM_ENABLE_TERMINFO=OFF

  -DLLVM_ENABLE_LLD=ON
  -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON
)

cmake "${cmake_args[@]}" "$BUILDDIR/llvm"
ninja ${JOBS:+-j $JOBS}
ninja ${JOBS:+-j $JOBS} install

host_triple=$("$INSTALLROOT/bin/clang" -dumpmachine)

cat > "$INSTALLROOT/bin/clang++.cfg" <<EOF
--target=$host_triple
-stdlib=libc++
-rtlib=compiler-rt
-unwindlib=libunwind
-fuse-ld=lld
-L$INSTALLROOT/lib64
-Wl,-rpath,$INSTALLROOT/lib64
EOF
ln -sf clang++.cfg "$INSTALLROOT/bin/clang.cfg"

ln -sf clang   "$INSTALLROOT/bin/cc"
ln -sf clang++ "$INSTALLROOT/bin/c++"
