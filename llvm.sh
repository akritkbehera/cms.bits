package: llvm
version: 23.1.3
variables:
 llvmCommit: a241dacf7844d832e7177b544a08abc7f029ee85
 llvmBranch: cms/llvmorg-23.1.3
 iwyuCommit: c9cbc836a1af631610266c53cf1671b1671a0fdc
 iwyuBranch: clang_23
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
 - libffi
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE1}" \
    -C "$BUILDDIR"
mkdir -p "$BUILDDIR/$PKGNAME-$PKGVERSION"
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR/$PKGNAME-$PKGVERSION" --strip-components=1

mv "$BUILDDIR/iwyu-%(version)s-%(iwyuCommit)s" "$BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/include-what-you-use"
sed -ibak '/add_clang_subdirectory(libclang)/a add_subdirectory(include-what-you-use)' $BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/CMakeLists.txt

rm -rf $BUILDDIR/build && mkdir -p $BUILDDIR/build && cd $BUILDDIR/build

host_triple=$(gcc -dumpmachine)

# Build LLVM only for the CPU architecture we are on; NVPTX is only needed when
# CUDA is in the build (mirrors cmsdist llvm.spec).
llvm_targets="Native"
if [ -n "$CUDA_ROOT" ]; then
  llvm_targets="Native;NVPTX"
fi

cmake_args=(
  -G Ninja
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;mlir;lld"
  -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;compiler-rt;openmp"
  -DIWYU_RESOURCE_RELATIVE_TO="iwyu"
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE:STRING=Release
  -DLLVM_INSTALL_UTILS=ON
  -DLLVM_LIBDIR_SUFFIX:STRING=64
  -DLLVM_BUILD_LLVM_DYLIB:BOOL=ON
  -DLLVM_LINK_LLVM_DYLIB:BOOL=ON
  -DLLVM_ENABLE_EH:BOOL=ON
  -DLLVM_ENABLE_PIC:BOOL=ON
  -DLLVM_ENABLE_RTTI:BOOL=ON
  -DCOMPILER_RT_INCLUDE_TESTS=OFF
  -DLLVM_INCLUDE_TESTS=OFF
  -DLLVM_HOST_TRIPLE="${host_triple}"
  -DLLVM_TARGETS_TO_BUILD:STRING="${llvm_targets}"
  -DCMAKE_REQUIRED_INCLUDES="${ZLIB_ROOT}/include"
  -DCMAKE_PREFIX_PATH="${ZLIB_ROOT};${LIBXML2_ROOT};${ZSTD_ROOT};${LIBUNWIND_ROOT}"
)

if [ -z "${use_system_gcc}" ]; then
  cmake_args+=(-DLLVM_BINUTILS_INCDIR:STRING="${GCC_ROOT}/include")
fi

if [ -n "$CUDA_ROOT" ]; then
  cmake_args+=(
    -DLIBOMPTARGET_NVPTX_ALTERNATE_HOST_COMPILER=/usr/bin/gcc
    -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITIES="${omptarget_cuda_archs}"
  )
fi

cmake "${cmake_args[@]}" "$BUILDDIR/$PKGNAME-$PKGVERSION/$PKGNAME"

# Configure build-tree tools before running them, as in cmsdist llvm.spec.
if [ -z "${use_system_gcc}" ]; then
  printf '%%s\n' "--gcc-toolchain=$GCC_ROOT" "--target=$host_triple" > bin/clang++.cfg
  ln -s clang++.cfg bin/clang.cfg
fi

ninja -v ${JOBS:+-j $JOBS} install
bin/clang-tidy --checks=* --list-checks | grep cms-handle

# Create libomp symlink
ln -s ${host_triple}/libomp.so $INSTALLROOT/lib64/libomp.so

# Install clang python bindings
BINDINGS_PATH=$INSTALLROOT/lib64/python%(python_major_minor)s/site-packages
DISTINFO_DIR=${BINDINGS_PATH}/libclang-%(version)s.dist-info
mkdir -p ${DISTINFO_DIR}
cp -r $BUILDDIR/$PKGNAME-$PKGVERSION/clang/bindings/python/clang $BINDINGS_PATH
cat > ${DISTINFO_DIR}/METADATA <<EOF
Metadata-Version: 2.1
Name: libclang
Version: %(version)s
Summary: Python bindings for libclang
EOF

rm -f $BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/scan-build/set-xcode*
find $BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/scan-build -exec install {} $INSTALLROOT/bin \;
find $BUILDDIR/$PKGNAME-$PKGVERSION/clang/tools/scan-view -type f -exec install {} $INSTALLROOT/bin \;
rm -f $INSTALLROOT/bin/FileRadar.scpt $INSTALLROOT/bin/GetRadarVersion.scpt
rm -f $INSTALLROOT/bin/set-xcode-analyzer

if [ -z "${use_system_gcc}" ]; then
  mv bin/clang++.cfg "$INSTALLROOT/bin/clang++.cfg"
  mv bin/clang.cfg "$INSTALLROOT/bin/clang.cfg"
fi

