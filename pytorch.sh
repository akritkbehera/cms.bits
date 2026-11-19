package: pytorch
version: "2.6.0"
tag: "2.6.0"
sources: 
- git+https://github.com/pytorch/pytorch?obj=main/v%(version)s&export=pytorch-%(version)s&submodules=1&output=/pytorch-%(version)s.tgz
- file://sources/FindEigen3.cmake.file
patches:
- pytorch-missing-braces.patch
- pytorch-2.6-system-fmt.patch
build_requires:
- CMake 
- ninja
- setuptools
requires:
- cuda
- cudnn
- gcc
- eigen
- fxdiv
- numactl
- openmpi
- protobuf
- abseil-cpp
- psimd
- Python
- py-PyYAML
- OpenBLAS
- zlib
- fmt
- py-pybind11
- py-typing-extensions
---
#!include <microarch-flags.file>
mkdir -p $BUILDDIR/$PKGNAME-$PKGVERSION/
pushd $BUILDDIR/$PKGNAME-$PKGVERSION/

tar -xzf "$SOURCEDIR"/$SOURCE0 \
    --strip-components=1 \
    -C "$BUILDDIR/$PKGNAME-$PKGVERSION"

cp "$SOURCEDIR/FindEigen3.cmake.file" "$BUILDDIR/$PKGNAME-$PKGVERSION/cmake/Modules/FindEigen3.cmake"

patch -p1 < $SOURCEDIR/$PATCH0
patch -p1 < $SOURCEDIR/$PATCH1
popd

rm -rf build; mkdir build; cd build

USE_CUDA=OFF

if [ -z "${WITHOUT_CUDA}" ]; then
  if [ "${cuda_gcc_support}" = "true" ]; then
    USE_CUDA=ON
  fi
fi

cmake_args=(
  $BUILDDIR/$PKGNAME-$PKGVERSION
  -G Ninja
  -Wno-dev
  -L
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_INSTALL_LIBDIR=lib
  -DCMAKE_C_FLAGS="${selected_microarch}"
  -DCMAKE_CXX_FLAGS="${selected_microarch}"
  -DBUILD_TEST=OFF
  -DBUILD_BINARY=OFF
  -DBUILD_PYTHON=OFF
  -DUSE_CUSPARSELT=OFF
  -DUSE_CUDSS=OFF
  -DUSE_NCCL=OFF
  -DUSE_ROCM=OFF
  -DUSE_XPU=OFF
  -DUSE_FBGEMM=OFF
  -DUSE_KINETO=OFF
  -DUSE_MAGMA=OFF
  -DUSE_MPS=OFF
  -DUSE_NNPACK=OFF
  -DUSE_NUMA=ON
  -DUSE_ROOT_DIR="$NUMACTL_ROOT"
  -DUSE_NUMPY=OFF
  -DUSE_OPENMP=ON
  -DUSE_QNNPACK=OFF
  -DUSE_PYTORCH_QNNPACK=OFF
  -DUSE_VALGRIND=OFF
  -DUSE_XNNPACK=OFF
  -DUSE_MKLDNN=OFF
  -DUSE_DISTRIBUTED=OFF
  -DUSE_MPI=ON
  -DUSE_GLOO=OFF
  -DUSE_TENSORPIPE=OFF
  -DONNX_ML=ON
  -DBLAS=OpenBLAS
  -DBUILD_CUSTOM_PROTOBUF=OFF
  -DUSE_SYSTEM_EIGEN_INSTALL=ON
  -DUSE_SYSTEM_PSIMD=ON
  -DUSE_SYSTEM_FXDIV=ON
  -DUSE_SYSTEM_PYBIND11=ON
  -DUSE_SYSTEM_BENCHMARK=OFF
  -DPYTHON_EXECUTABLE=${PYTHON_ROOT}/bin/python3
  -DCMAKE_PREFIX_PATH="${EIGEN_ROOT};${FXDIV_ROOT};${NUMACTL_ROOT};${OPENMPI_ROOT};${PROTOBUF_ROOT};${PSIMD_ROOT};${PYTHON_ROOT};${PY_PYYAML_ROOT};${OPENBLAS_ROOT};${ZLIB_ROOT};${FMT_ROOT};${PY_PYBIND11_ROOT};${PY_TYPING_EXTENSIONS_ROOT}"
  -DCMAKE_FIND_DEBUG_MODE=ON
)

if [ -z "${WITHOUT_CUDA}" ]; then
  cmake_args+=(
    -DUSE_CUDA=${USE_CUDA} 
    -DTORCH_CUDA_ARCH_LIST="6.0 7.0 7.5 8.0 8.9 9.0+PTX"
    -Dnvtx3_dir=${CUDA_ROOT}/include 
    -DUSE_CUDNN=${USE_CUDA} 
    -DCUDNN_ROOT=${CUDNN_ROOT}
  )
else
  cmake_args+=(
    -DUSE_CUDA=OFF 
    -DUSE_CUDNN=OFF 
  )
fi

cmake "${cmake_args[@]}"
ninja -v ${JOBS:+-j$JOBS} install
