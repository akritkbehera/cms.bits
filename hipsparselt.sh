package: hipsparselt
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-libraries.git?obj=develop/rocm-%(version)s&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - py-packaging
requires:
  - gcc
  - rocm-hip
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - hipsparse
  - msgpack-cxx
  - rocm-smi-lib
  - rocminfo
  - roctracer
  - boost
  - py-joblib
  - py-PyYAML
  - py-msgpack
  - Python
---
# ROCm library package: builds rocm-libraries/projects/<pkg> with amdclang (port of
# cmsdist rocm-libraries-build). Will not build without a full ROCm toolchain + AMD GPU.
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"

tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

CMAKE_ARGS=(
  -B "$BUILDDIR/build"
  -S "$BUILDDIR/rocm-libraries/projects/hipsparselt"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang"
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang++"
  -DCMAKE_PREFIX_PATH="$ROCM_HIP_ROOT;$ROCM_CORE_ROOT;$ROCM_LLVM_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT"
  -DBUILD_CLIENTS_TESTS=off
  -DHIP_ROOT=$ROCM_HIP_ROOT
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102"
  -DGPU_TARGETS="gfx942"
  -DHIPSPARSELT_ENABLE_CLIENT=OFF
  -DHIPSPARSELT_ENABLE_FORTRAN=OFF
  -DCMAKE_CXX_FLAGS="-I$BOOST_ROOT/include -I$ROCTRACER_ROOT/include"
  # As in hipblaslt: the spec's $PYTHON3_ROOT does not exist here (the package is
  # `Python`), so pin the tree's Python rather than letting the venv's 3.9 win.
  -DPython3_FIND_VIRTUALENV=STANDARD
  -DPython3_ROOT_DIR="$PYTHON_ROOT"
  -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12"
  -DPython3_INCLUDE_DIR="$PYTHON_ROOT/include/python3.12"
)
cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
