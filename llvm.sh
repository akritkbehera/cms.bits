package: llvm
version: 18.1.6
variables:
 llvmCommit: 02c7568fc9f555b2c72fc169c8c68e2116d97382
 llvmBranch: cms/release/18.x/1118c2e
 iwyuCommit: 377eaef70cdda47368939f4d9beabfabe3f628f0
 iwyuBranch: clang_18
sources:
 - git+https://github.com/cms-externals/llvm-project.git?obj=%(llvmBranch)s/%(llvmCommit)s&export=llvm-%(version)s-%(llvmCommit)s&module=llvm-%(version)s-%(llvmCommit)s&output=/llvm-%(version)s-%(llvmCommit)s.tgz
 - git+https://github.com/include-what-you-use/include-what-you-use.git?obj=%(iwyuBranch)s/%(iwyuCommit)s&export=iwyu-%(version)s-%(iwyuCommit)s&module=iwyu-%(version)s-%(iwyuCommit)s&output=/iwyu-%(version)s-%(iwyuCommit)s.tgz
build_requires:
 - CMake
 - ninja
requires:
 - gcc
 - zlib
 - Python
 - libxml2
 - zstd
 - libunwind
 - cuda
---
tar -xzf "$SOURCEDIR/${SOURCE1}" \
    -C "$BUILDDIR" 

mv $BUILDDIR/iwyu-* $BUILDDIR/include-what-you-use
pushd $BUILDDIR/include-what-you-use
    sed -ibak '/add_clang_subdirectory(libclang)/a add_subdirectory(include-what-you-use)' CMakeLists.txt
popd

mkdir -p "$BUILDDIR/$PKGNAME-$PKGVERSION"
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR/$PKGNAME-$PKGVERSION" --strip-components=1

rm -rf ../build && mkdir -p ../build && cd ../build

host_triple=$(gcc -dumpmachine)

cmake_args=(
  -G Ninja
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt;lld;openmp"
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE:STRING=Release
  -DLLVM_LIBDIR_SUFFIX:STRING=64
  -DLLVM_BUILD_LLVM_DYLIB:BOOL=ON
  -DLLVM_LINK_LLVM_DYLIB:BOOL=ON
  -DLLVM_ENABLE_EH:BOOL=ON
  -DLLVM_ENABLE_PIC:BOOL=ON
  -DLLVM_ENABLE_RTTI:BOOL=ON
  -DLLVM_HOST_TRIPLE="${host_triple}"
  -DLLVM_TARGETS_TO_BUILD:STRING="X86;PowerPC;AArch64;RISCV;NVPTX"
  -DCMAKE_REQUIRED_INCLUDES="${ZLIB_ROOT}/include"
  -DCMAKE_PREFIX_PATH="${ZLIB_ROOT};${LIBXML2_ROOT};${ZSTD_ROOT};${LIBUNWIND_ROOT}"
)

if [ -n "${use_system_gcc}" ]; then
  cmake_args+=(-DLLVM_BINUTILS_INCDIR:STRING="${GCC_ROOT}/include")
fi

if [ -z "${without_cuda}" ]; then
  cmake_args+=(
    -DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=/usr/bin/gcc
    -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES="${omptarget_cuda_archs}"
  )
fi

cmake "${cmake_args[@]}" "$BUILDDIR/$PKGNAME-$PKGVERSION/$PKGNAME"
ninja -v ${JOBS+-j $JOBS}
ninja -v ${JOBS+-j $JOBS} check-clang-tools
ninja -v ${JOBS+-j $JOBS} install

BINDINGS_PATH=$INSTALLROOT/lib64/python%(python_major_minor)s/site-packages
PKG_INFO_FILE=$BINDINGS_PATH/clang-$PKG_VERSION-py%(python_major_minor)s.egg-info/PKG-INFO
mkdir -p $BINDINGS_PATH
cp -r $BUILDDIR/$PKGNAME-$PKGVERSION/clang/bindings/python/clang $BINDINGS_PATH
mkdir $BINDINGS_PATH/clang-$PKG_VERSION-py%(python_major_minor)s.egg-info
echo -e "Metadata-Version: 1.1\nName: clang\nVersion: $PKG_VERSION" > ${PKG_INFO_FILE}

rm -f $BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/scan-build/set-xcode*
find $BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/scan-build -exec install {} $INSTALLROOT/bin \;
find $BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/scan-view -type f -exec install {} $INSTALLROOT/bin \;
rm -f $INSTALLROOT/bin/FileRadar.scpt $INSTALLROOT/bin/GetRadarVersion.scpt
rm -f $INSTALLROOT/bin/set-xcode-analyzer

if [ -n "${use_system_gcc}" ]; then
    pushd $INSTALLROOT/bin
        [ -e clang++.cfg ] && exit 1
        [ -e clang.cfg   ] && exit 1
        echo "--gcc-toolchain=$GCC_ROOT" > clang++.cfg
        echo "--target=$host_triple"    >> clang++.cfg
        ln -s clang++.cfg clang.cfg
    popd
fi