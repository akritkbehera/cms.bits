package: rocprofiler-compute
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
build_requires:
  - CMake
  - gmake
  - rocm-cmake
requires:
  - gcc
  - rocm-core
  - rocm-llvm
  - rocr-runtime
  - Python
  - rocprofiler
  - roctracer
  - rocm-hip
  - libxml2
  - rocm-rocprofiler-sdk
  - elfutils
  # The build asserts every entry of the project's requirements.txt is importable in the
  # Python it resolves, so all of them have to be present here.
  - py-astunparse
  - py-colorlover
  - py-kaleido
  - py-matplotlib
  - py-numpy
  - py-pandas
  - py-plotext
  - py-plotille
  - py-pymongo
  - py-PyYAML
  - setuptools
  - py-sqlalchemy
  - py-tabulate
  - py-textual
  - py-tqdm
  - py-textual-plotext
  - py-textual-fspicker
  - py-dash-bootstrap-components
  - py-dash-svg
  - py-dash
---
# ROCm (rocm-systems monorepo) package -- port of cmsdist rocprofiler-compute.spec.
export PKG_CONFIG_PATH="${ELFUTILS_ROOT}/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_C_COMPILER="${ROCM_LLVM_ROOT}/bin/amdclang" -DCMAKE_CXX_COMPILER="${ROCM_LLVM_ROOT}/bin/amdclang++" -DBUILD_TESTING=OFF -DPython3_FIND_VIRTUALENV=STANDARD -DPython3_ROOT_DIR="$PYTHON_ROOT" -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12"'
# Prebuilt roofline binaries for other distros / ROCm majors are not usable here.
export ROCM_POST_INSTALL_HOOK='rm -fr "$INSTALLROOT"/bin/roofline-rhel8-rocm6 "$INSTALLROOT"/bin/roofline-sles15sp6-rocm6 "$INSTALLROOT"/bin/roofline-ubuntu22_04-rocm6 "$INSTALLROOT"/bin/roofline-azurelinux3-rocm7 "$INSTALLROOT"/bin/roofline-sles15sp6-rocm7 "$INSTALLROOT"/bin/roofline-ubuntu22_04-rocm7'
#!include <rocm-systems-build.sh>
