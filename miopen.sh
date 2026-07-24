package: miopen
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-libraries.git?obj=develop/rocm-%(version)s&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
  - https://raw.githubusercontent.com/suruoxi/half/refs/heads/master/include/half.hpp
patches:
  - miopen-boost-optional-fix.patch
build_requires:
  - CMake
  - gmake
  - rocm-cmake
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
  - json
  - hipblas-common
  - boost
  - zstd
  - opencl
---
# ROCm library package: builds rocm-libraries/projects/<pkg> with amdclang (port of
# cmsdist miopen.spec + rocm-libraries-build).
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"

tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"
cp "$SOURCEDIR/$SOURCE1" "$BUILDDIR"

# Patch paths are projects/miopen/... so strip both components from the project dir.
patch -p2 -d "$BUILDDIR/rocm-libraries/projects/miopen" < "$SOURCEDIR/$PATCH0"

# MIOpen expects half.hpp under a `half/` directory (HALF_INCLUDE_DIR points at the parent).
mkdir -p "$BUILDDIR/half-include/half"
cp "$SOURCEDIR/$SOURCE1" "$BUILDDIR/half-include/half/"

# Stub out clang-tidy: the real module runs checks that are not part of this build.
printf 'macro(enable_clang_tidy)\nendmacro()\nmacro(clang_tidy_check)\nendmacro()\n' \
  > "$BUILDDIR/rocm-libraries/projects/miopen/cmake/ClangTidy.cmake"

CMAKE_ARGS=(
  -B "$BUILDDIR/build"
  -S "$BUILDDIR/rocm-libraries/projects/miopen"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang"
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang++"
  -DCMAKE_PREFIX_PATH="$ROCM_HIP_ROOT;$ROCM_CORE_ROOT;$ROCM_LLVM_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT"
  -DBUILD_CLIENTS_TESTS=off
  -DHIP_ROOT=$ROCM_HIP_ROOT
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102"
  -DCK_USE_ALTERNATIVE_PYTHON="$PYTHON_ROOT/bin/python3"
  # composable_kernel and rocMLIR are not built here, so MIOpen must not look for them.
  -DMIOPEN_USE_COMPOSABLEKERNEL=OFF
  -DMIOPEN_USE_MLIR=OFF
  -DMIOPEN_USE_COMGR=ON
  -DBoost_USE_STATIC_LIBS=OFF
  -DMIOPEN_ENABLE_AI_KERNEL_TUNING=OFF
  -DMIOPEN_ENABLE_AI_IMMED_MODE_FALLBACK=OFF
  -DMIOPEN_BACKEND=HIP
  -DMIOPEN_BUILD_DRIVER=OFF
  -DHALF_INCLUDE_DIR="$BUILDDIR/half-include"
  -DBUILD_TESTING=OFF
)
cmake "${CMAKE_ARGS[@]}"

# Drop the trailing block of CMakeLists.txt after configuring (as the spec does).
sed -i '827,830d' "$BUILDDIR/rocm-libraries/projects/miopen/CMakeLists.txt"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
