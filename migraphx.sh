package: migraphx
version: "7.14"
sources:
 - https://github.com/ROCm/AMDMIGraphX/archive/refs/tags/rocm-%(version)s.tar.gz
patches:
 - migraphx-rocm-add-version-resource.patch
 - migraphx-cxx20-accumulate.patch
 - migraphx-without-hipblaslt.patch
 - migraphx-without-mlir.patch
 - migraphx-tf-proto-names.patch
build_requires:
 - CMake
 - rocm-cmake
requires:
 - gcc
 - rocm-hip
 - rocm-core
 - rocm-llvm
 - rocr-runtime
 - rocm-comgr
 - miopen
 - rocblas
 - protobuf
 - abseil-cpp
 - json
 - msgpack-cxx
 - sqlite
 - eigen
 - boost
 - zlib
---
#!include <rocm-flags.file>
tar -xzf "$SOURCEDIR/$SOURCE0" --strip-components=1 -C "$BUILDDIR"
for ((num=0; num<PATCH_COUNT; num++)); do
  patch_var="PATCH${num}"
  patch -p1 < "$SOURCEDIR/${!patch_var}"
done
sed -i -e 's|-std=c++17>|-std=c++%(cms_cxx_std)s>|' CMakeLists.txt
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"
cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s -DCMAKE_CXX_FLAGS=-fno-cxx-modules \
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang" \
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang++" \
  -DCMAKE_PREFIX_PATH="$ROCM_CMAKE_ROOT;$ROCM_CORE_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$MIOPEN_ROOT;$ROCBLAS_ROOT;$PROTOBUF_ROOT;$ABSEIL_CPP_ROOT;$JSON_ROOT;$MSGPACK_CXX_ROOT;$SQLITE_ROOT;$EIGEN_ROOT;$BOOST_ROOT;$ZLIB_ROOT" \
  -DHIP_ROOT="$ROCM_HIP_ROOT" -DGPU_TARGETS="$rocm_targets" \
  -DBUILD_TESTING=OFF -DROCM_ENABLE_CLANG_TIDY=OFF \
  -DMIGRAPHX_ENABLE_PYTHON=OFF -DMIGRAPHX_ENABLE_MLIR=OFF \
  -DMIGRAPHX_USE_COMPOSABLEKERNEL=OFF -DMIGRAPHX_USE_AMDMLSS=OFF \
  -DMIGRAPHX_USE_MIOPEN=ON -DMIGRAPHX_USE_ROCBLAS=ON -DMIGRAPHX_USE_HIPBLASLT=OFF
cmake --build "$BUILDDIR/build" --parallel "${JOBS:-1}" --verbose
cmake --install "$BUILDDIR/build" --verbose
