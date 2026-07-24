package: rocprofiler-compute
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/rocm-rel-7.2/rocm-%(version)s&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
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
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

CMAKE_ARGS=(
  -S "$BUILDDIR/rocm-systems/projects/rocprofiler-compute"
  -B "$BUILDDIR/build"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_PREFIX_PATH="$ROCM_CORE_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_LLVM_ROOT;$ROCM_HIP_ROOT;$ROCM_COMGR_ROOT"
  -DCMAKE_C_COMPILER="${ROCM_LLVM_ROOT}/bin/amdclang"
  -DCMAKE_CXX_COMPILER="${ROCM_LLVM_ROOT}/bin/amdclang++"
  -DBUILD_TESTING=OFF
  # CMake's FindPython3 prefers an activated virtualenv over Python3_ROOT_DIR, which here
  # means the venv's 3.9 -- where none of the py- dependencies above are installed.
  -DPython3_FIND_VIRTUALENV=STANDARD
  -DPython3_ROOT_DIR="$PYTHON_ROOT"
  -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12"
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi
cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1

# Prebuilt roofline binaries for other distros / ROCm majors are not usable here.
rm -fr "$INSTALLROOT"/bin/roofline-rhel8-rocm6 "$INSTALLROOT"/bin/roofline-sles15sp6-rocm6 "$INSTALLROOT"/bin/roofline-ubuntu22_04-rocm6
rm -fr "$INSTALLROOT"/bin/roofline-azurelinux3-rocm7 "$INSTALLROOT"/bin/roofline-sles15sp6-rocm7 "$INSTALLROOT"/bin/roofline-ubuntu22_04-rocm7
