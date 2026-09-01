package: hipsparselt
version: "7.14"
build_requires:
  - CMake
  - gmake
  - rocm-cmake
  - py-packaging
  - rocm-sources
requires:
  - gcc
  - rocm-hip
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - rocm-comgr
  - hipsparse
  - origami
  - zlib
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
# As in hipblaslt: the spec's $PYTHON3_ROOT does not exist here (the package is
# `Python`), so pin the tree's Python rather than letting the venv's 3.9 win.
export ROCM_CMAKE_EXTRA_ARGS='-DGPU_TARGETS="gfx942" -DHIPBLASLT_ENABLE_THEROCK=ON -DHIPSPARSELT_ENABLE_CLIENT=OFF -DHIPSPARSELT_ENABLE_FORTRAN=OFF -DCMAKE_CXX_FLAGS="$ROCM_DEVICE_LIB_FLAG -I$BOOST_ROOT/include -I$ROCTRACER_ROOT/include" -DPython3_FIND_VIRTUALENV=STANDARD -DPython3_ROOT_DIR="$PYTHON_ROOT" -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12" -DPython3_INCLUDE_DIR="$PYTHON_ROOT/include/python3.12"'
#!include <rocm-libraries-build.sh>
