package: rocm-llvm
version: "7.14"
sources:
  - git+https://github.com/ROCm/llvm-project?obj=release/therock-%(version)s/HEAD&export=rocm-llvm-%(version)s&output=/source.tar.gz
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - ninja
  - rocm-cmake
requires:
  - ninja
  - rocm-core
  - libxml2
  - zlib
  - rocprofiler-register
  - gcc
prepend_path:
  PATH: "%(root_dir)s/lib/llvm/bin"
  LD_LIBRARY_PATH: "%(root_dir)s/lib/llvm/lib"
env:
  HIP_CLANG_PATH: "$ROCM_LLVM_ROOT/lib/llvm/bin"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"

mkdir -p "$BUILDDIR/rocm-systems"
tar -xzf "$SOURCEDIR/${SOURCE1}" --strip-components=1 -C "$BUILDDIR/rocm-systems"
cp -rT "$BUILDDIR/rocm-systems/projects/rocr-runtime/runtime/hsa-runtime" "$BUILDDIR/hsa-runtime"

CMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$LIBXML2_ROOT;$ZLIB_ROOT;$ROCPROFILER_REGISTER_ROOT"
# RUNTIMES_CMAKE_ARGS is itself a ';'-separated cmake list, so the nested
# CMAKE_PREFIX_PATH separators must be escaped to survive list splitting.
RUNTIMES_PREFIX_PATH="${CMAKE_PREFIX_PATH//;/\\;}"

host_triple=$(gcc -dumpmachine)
cmake -G Ninja \
  -S "$BUILDDIR/llvm" \
  -B "$BUILDDIR/build-llvm" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT/lib/llvm" \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s \
  -DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH" \
  -DLLVM_TARGETS_TO_BUILD="AMDGPU;X86" \
  -DLLVM_ENABLE_PROJECTS="clang;lld;clang-tools-extra" \
  -DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx;openmp" \
  -DLLVM_ENABLE_ZLIB=ON \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_INSTALL_UTILS=ON \
  -DLLVM_ENABLE_PIC=ON \
  -DLLVM_INSTALL_STATIC_LIBS=ON \
  -DLLVM_BUILD_LLVM_DYLIB:BOOL=ON \
  -DLLVM_LINK_LLVM_DYLIB:BOOL=ON \
  -DLLVM_DYLIB_EXPORT_ALL=ON \
  -DPACKAGE_VENDOR=AMD \
  -DCLANG_DEFAULT_LINKER=lld \
  -DCLANG_ENABLE_AMDCLANG=ON \
  -DCLANG_DEFAULT_PIE_ON_LINUX=OFF \
  -DLLVM_HOST_TRIPLE=$host_triple \
  -DBUILD_TESTING=OFF \
  -DRUNTIMES_CMAKE_ARGS="-DLIBUNWIND_USE_COMPILER_RT=ON;-DCMAKE_PREFIX_PATH=${RUNTIMES_PREFIX_PATH};-DLIBOMPTARGET_HSA_INCLUDE_DIRS=$BUILDDIR/hsa-runtime/inc;-DLIBOMPTARGET_NO_SANITIZER_AMDGPU=ON;-DOFFLOAD_EXTERNAL_PROJECT_UNIFIED_ROCR=OFF"

# Point the freshly-built clang at the bits gcc toolchain + its libstdc++ (lib64),
# otherwise the runtimes/openmp link step resolves libstdc++ symbols (e.g.
# _M_replace_cold) against an older/system libstdc++ and fails.
echo -e "--gcc-toolchain=$GCC_ROOT\n--target=$host_triple\n-m64\n-L$GCC_ROOT/lib64" > "$BUILDDIR/build-llvm/bin/clang++.cfg"
ln -sf "$BUILDDIR/build-llvm/bin/clang++.cfg" "$BUILDDIR/build-llvm/bin/clang.cfg"
ln -sf "$BUILDDIR/build-llvm/bin/clang++.cfg" "$BUILDDIR/build-llvm/bin/$host_triple.cfg"

ninja -v -C "$BUILDDIR/build-llvm" ${JOBS:+-j$JOBS}

cmake -G Ninja \
  -S "$BUILDDIR/amd/device-libs" \
  -B "$BUILDDIR/build-device-libs" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_C_COMPILER="$BUILDDIR/build-llvm/bin/clang" \
  -DCMAKE_CXX_COMPILER="$BUILDDIR/build-llvm/bin/clang++" \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_PREFIX_PATH="$BUILDDIR/build-llvm;$CMAKE_PREFIX_PATH"
ninja -v -C "$BUILDDIR/build-device-libs" ${JOBS:+-j$JOBS}

cmake -G Ninja \
  -S "$BUILDDIR/amd/hipcc" \
  -B "$BUILDDIR/build-hip" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_C_COMPILER="$BUILDDIR/build-llvm/bin/clang" \
  -DCMAKE_CXX_COMPILER="$BUILDDIR/build-llvm/bin/clang++" \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DCMAKE_PREFIX_PATH="$BUILDDIR/build-llvm;$CMAKE_PREFIX_PATH"
ninja -v -C "$BUILDDIR/build-hip" ${JOBS:+-j$JOBS}

# Install
ninja -v -C "$BUILDDIR/build-llvm" ${JOBS:+-j$JOBS} install
ninja -v -C "$BUILDDIR/build-llvm/runtimes/runtimes-bins" ${JOBS:+-j$JOBS} install
ninja -v -C "$BUILDDIR/build-llvm/runtimes/builtins-bins" ${JOBS:+-j$JOBS} install
ninja -v -C "$BUILDDIR/build-device-libs" install
ninja -v -C "$BUILDDIR/build-hip" install

mkdir -p "$INSTALLROOT/lib/llvm/bin/"
mv "$BUILDDIR/build-llvm/bin/clang++.cfg" "$INSTALLROOT/lib/llvm/bin/"
printf "\n--rocm-device-lib-path=%s/amdgcn/bitcode\n" "$INSTALLROOT" >> "$INSTALLROOT/lib/llvm/bin/clang++.cfg"

mkdir -p "$INSTALLROOT/.info"
echo "%(version)s" > "$INSTALLROOT/.info/version"

mkdir -p "$INSTALLROOT/bin"
ln -r -s -f "$INSTALLROOT/lib/llvm/bin/amdclang"     "$INSTALLROOT/bin/"
ln -r -s -f "$INSTALLROOT/lib/llvm/bin/amdclang++"   "$INSTALLROOT/bin/"
ln -r -s -f "$INSTALLROOT/lib/llvm/bin/amdclang-cl"  "$INSTALLROOT/bin/"
ln -r -s -f "$INSTALLROOT/lib/llvm/bin/amdclang-cpp" "$INSTALLROOT/bin/"
ln -r -s -f "$INSTALLROOT/lib/llvm/bin/amdflang"     "$INSTALLROOT/bin/"
ln -r -s -f "$INSTALLROOT/lib/llvm/bin/amdlld"       "$INSTALLROOT/bin/"
