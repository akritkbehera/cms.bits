package: miopen
version: "7.14"
sources:
  - https://raw.githubusercontent.com/suruoxi/half/7cd91f2a3b5feba92a0eb44ed314e0ddb9962d89/include/half.hpp
patches:
  - miopen-ciso646.patch
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - rocm-sources
requires:
  - gcc
  - rocm-hip
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - rocminfo
  - Python
  - roctracer
  - sqlite
  - hipblaslt
  - hipblas
  - rocblas
  - rocrand
  - bz2lib
  - google-test
  - eigen
  - json
  - hipblas-common
  - boost
  - zstd
  - opencl
---
# ROCm library package: builds rocm-libraries/projects/miopen with amdclang (port of
# cmsdist miopen.spec + rocm-libraries-build).
export ROCM_PRE_BUILD_HOOK='
cp "$SOURCEDIR/$SOURCE0" "$BUILDDIR"
patch -p1 -d "$BUILDDIR/rocm-libraries/projects/miopen" < "$SOURCEDIR/miopen-ciso646.patch"
mkdir -p "$BUILDDIR/half-include/half"
cp "$SOURCEDIR/$SOURCE0" "$BUILDDIR/half-include/half/"
printf "macro(enable_clang_tidy)\nendmacro()\nmacro(clang_tidy_check)\nendmacro()\n" > "$BUILDDIR/rocm-libraries/projects/miopen/cmake/ClangTidy.cmake"
'
export ROCM_CMAKE_EXTRA_ARGS='-DCK_USE_ALTERNATIVE_PYTHON="$PYTHON_ROOT/bin/python3" -DMIOPEN_USE_COMPOSABLEKERNEL=OFF -DMIOPEN_USE_MLIR=OFF -DMIOPEN_USE_COMGR=ON -DBoost_USE_STATIC_LIBS=OFF -DMIOPEN_ENABLE_AI_KERNEL_TUNING=OFF -DMIOPEN_ENABLE_AI_IMMED_MODE_FALLBACK=OFF -DMIOPEN_BACKEND=HIP -DMIOPEN_BUILD_DRIVER=OFF -DHALF_INCLUDE_DIR="$BUILDDIR/half-include" -DBUILD_TESTING=OFF'
# Drop the trailing block of CMakeLists.txt after configuring (as the spec does).
export ROCM_POST_CMAKE_HOOK='sed -i "/^if(CMAKE_CXX_COMPILER MATCHES/,/^endif()/d" "$BUILDDIR/rocm-libraries/projects/miopen/CMakeLists.txt"'

#!include <rocm-libraries-build.sh>
