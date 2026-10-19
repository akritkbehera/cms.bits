package: onnxruntime
version: 1.30.0
variables:
 tag: v%(version)s
 branch: main
 github_user: microsoft
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&submodules=1&output=/%(package)s-%(version)s.tgz
patches:
 - onnxruntime-cms-changes.patch
 - onnxruntime-ciso646.patch
 - onnxruntime-migraphx-plugin-exports.patch
 - onnxruntime-migraphx-cxx20.patch
 - onnxruntime-cuda-remove-const-ones.patch
 - onnxruntime-migraphx-user-compute-stream.patch
build_requires:
 - CMake
 - ninja
requires:
 - gcc
 - protobuf
 - abseil-cpp
 - py-numpy
 - py-onnx
 - zlib
 - libpng
 - py-pybind11
 - re2
 - eigen
 - json
 - migraphx
 - rocm-hip
 - rocr-runtime
 - rocm-comgr
 - rocm-core
 - rocm-llvm
 - miopen
 - rocblas
 - cuda
 - cudnn
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
#!include <cuda-flags.file>
tar -xzf "$SOURCEDIR/$SOURCE0" --strip-components=1 -C "$BUILDDIR"
for ((num=0; num<PATCH_COUNT; num++)); do
  patch_var="PATCH${num}"
  patch -p1 < "$SOURCEDIR/${!patch_var}"
done
mkdir -p "$BUILDDIR/build"
cd "$BUILDDIR/build"
cmake_args=(
  -G Ninja -Wno-dev
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" -DCMAKE_INSTALL_LIBDIR=lib
  -Donnxruntime_ENABLE_PYTHON=ON -Donnxruntime_BUILD_SHARED_LIB=ON
  -Donnxruntime_USE_CUDA=OFF -Donnxruntime_USE_MIGRAPHX=OFF
  -Donnxruntime_BUILD_CSHARP=OFF -Donnxruntime_ENABLE_MICROSOFT_INTERNAL=OFF
  -Donnxruntime_USE_TENSORRT=OFF -Donnxruntime_CROSS_COMPILING=OFF
  # Full protobuf duplicates ONNX descriptors when the CUDA plugin is loaded.
  -Donnxruntime_USE_FULL_PROTOBUF=OFF
  -Donnxruntime_DISABLE_CONTRIB_OPS=OFF -Donnxruntime_BUILD_UNIT_TESTS=OFF
  -Donnxruntime_USE_TELEMETRY=OFF -Donnxruntime_USE_FP4_QMOE=OFF
  -DCMAKE_DISABLE_FIND_PACKAGE_flatbuffers=ON
  -DCMAKE_PREFIX_PATH="$ZLIB_ROOT;$LIBPNG_ROOT;$PROTOBUF_ROOT;$PY_PYBIND11_ROOT;$RE2_ROOT;$EIGEN_ROOT;$JSON_ROOT;$MIGRAPHX_ROOT;$ROCM_HIP_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$ROCM_CORE_ROOT;$ROCM_LLVM_ROOT;$MIOPEN_ROOT;$ROCBLAS_ROOT;$ABSEIL_CPP_ROOT"
  -DCMAKE_CXX_FLAGS="-Wno-error=stringop-overflow -Wno-error=maybe-uninitialized -Wno-error=overloaded-virtual -Wno-error=cpp -Wno-error=free-nonheap-object"
)
if [ -z "${without_cuda:-}" ] && [ "${cuda_gcc_support:-true}" = true ]; then
  cmake_args+=(
    -Donnxruntime_USE_CUDA=ON
    -Donnxruntime_CUDA_HOME="$CUDA_ROOT" -Donnxruntime_CUDNN_HOME="$CUDNN_ROOT"
    -Donnxruntime_BUILD_CUDA_EP_AS_PLUGIN=ON -Donnxruntime_NVCC_THREADS=1
    -DCMAKE_CUDA_ARCHITECTURES="${cuda_arch// /;}"
    -DCMAKE_CUDA_FLAGS="-isystem $PROTOBUF_ROOT/include -DTHRUST_IGNORE_DEPRECATED_API -DCUB_IGNORE_DEPRECATED_API -Wno-deprecated-gpu-targets --static-global-template-stub=false -cudart shared"
    -DCMAKE_CUDA_RUNTIME_LIBRARY=Shared
    -DCMAKE_TRY_COMPILE_PLATFORM_VARIABLES=CMAKE_CUDA_RUNTIME_LIBRARY
  )
fi
python_build_args=()
if [ -z "${without_rocm:-}" ]; then
  cmake_args+=(-Donnxruntime_USE_MIGRAPHX=ON -Donnxruntime_MIGRAPHX_HOME="$MIGRAPHX_ROOT")
  python_build_args+=(--use_migraphx)
fi
cmake "${cmake_args[@]}" "$BUILDDIR/cmake"
cmake --build . --parallel "${JOBS:-1}" --verbose
python3 "$BUILDDIR/setup.py" build "${python_build_args[@]}"
cmake --install .
mkdir -p "$INSTALLROOT/$PYTHON3_LIB_SITE_PACKAGES"
mv build/lib/onnxruntime "$INSTALLROOT/$PYTHON3_LIB_SITE_PACKAGES/"
