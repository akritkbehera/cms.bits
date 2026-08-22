package: hipblaslt
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-libraries.git?obj=release/therock-%(version)s/HEAD&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
patches:
  - rocm-libraries.patch
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
  - hipblas-common
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
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_CXX_FLAGS="$ROCM_DEVICE_LIB_FLAG -I$ROCTRACER_ROOT/include" -DHIPBLASLT_ENABLE_DEVICE=off -DHIPBLASLT_ENABLE_CLIENT=off -DORIGAMI_BUILD_TESTING=off -DHIPBLASLT_ENABLE_ROCROLLER=OFF -DPython3_FIND_VIRTUALENV=STANDARD -DPython3_ROOT_DIR="$PYTHON_ROOT" -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12" -DPython3_INCLUDE_DIR="$PYTHON_ROOT/include/python3.12"'
#!include <rocm-libraries-build.sh>
