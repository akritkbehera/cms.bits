package: hipblaslt
version: "7.14"
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
  - hipblas-common
  - origami
  - stinkytofu
  - roctracer
  - rocm-smi-lib
  - msgpack-cxx
  - boost
  - google-test
  - amdsmi
  - Python
---
# The spec says $PYTHON3_ROOT, but this tree's package is `Python`, so the variable is
# $PYTHON_ROOT -- $PYTHON3_ROOT expands to nothing and the setting is silently lost.
# CMake then falls back to the activated venv (3.9, no headers) and Development.Module
# comes up missing, so pin the tree's Python explicitly.
export ROCM_CMAKE_EXTRA_ARGS='-DHIPBLASLT_ENABLE_THEROCK=ON -DCMAKE_CXX_FLAGS="$ROCM_DEVICE_LIB_FLAG -I$ROCTRACER_ROOT/include" -DHIPBLASLT_ENABLE_DEVICE=off -DHIPBLASLT_ENABLE_CLIENT=off -DHIPBLASLT_ENABLE_ROCROLLER=OFF -DPython3_FIND_VIRTUALENV=STANDARD -DPython3_ROOT_DIR="$PYTHON_ROOT" -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12" -DPython3_INCLUDE_DIR="$PYTHON_ROOT/include/python3.12"'
#!include <rocm-libraries-build.sh>
