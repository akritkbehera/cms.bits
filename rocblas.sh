package: rocblas
version: "7.2.4"
sources:
  - git+https://github.com/ROCm/rocm-libraries.git?obj=develop/rocm-%(version)s&export=rocm-libraries&submodules=1&output=/rocm-libraries.tar.gz
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
  - roctracer
  - hipblaslt
  - hipblas-common
  - Python
  - setuptools
  - pip
  - msgpack-cxx
  - boost
  - rocminfo
---
export HIP_DEVICE_LIB_PATH="$ROCM_LLVM_ROOT/amdgcn/bitcode"
# pip maps any PIP_<OPTION> environment variable onto its own --<option>, and --root is a
# real pip flag (DESTDIR-style staging). So bits' package-root variable for the `pip`
# package, PIP_ROOT, is read by pip as --root and everything gets installed under
# $PIP_ROOT/<absolute target path> instead of the target. Keep the path, drop the name.
# (cmsdist never sees this: its package is py3-pip, so the variable is PY3_PIP_ROOT.)
PIP_PKG_ROOT="$PIP_ROOT"
unset PIP_ROOT

export PYTHONPATH=$SETUPTOOLS_ROOT/lib/python3.12/site-packages:$PIP_PKG_ROOT/lib/python3.12/site-packages${PYTHONPATH:+:$PYTHONPATH}
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

# rocblas pip-installs Tensile into a nested virtualenv. Tensile is a legacy setup.py
# project with no pyproject.toml, so pip builds it in an isolated environment that has to
# fetch setuptools from an index -- which fails here. The flag makes it use the setuptools
# already on PYTHONPATH instead. It has to be the flag: pip ignores PIP_NO_BUILD_ISOLATION.
sed -i 's|-m pip install \${ARGN}|-m pip install --no-build-isolation ${ARGN}|' \
  "$BUILDDIR/rocm-libraries/projects/rocblas/cmake/virtualenv.cmake"
grep -q -- '--no-build-isolation' "$BUILDDIR/rocm-libraries/projects/rocblas/cmake/virtualenv.cmake"

CMAKE_ARGS=(
  -B "$BUILDDIR/build"
  -S "$BUILDDIR/rocm-libraries/projects/rocblas"
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_C_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang"
  -DCMAKE_CXX_COMPILER="$ROCM_LLVM_ROOT/bin/amdclang++"
  -DCMAKE_PREFIX_PATH="$ROCM_HIP_ROOT;$ROCM_CORE_ROOT;$ROCM_LLVM_ROOT;$ROCR_RUNTIME_ROOT;$ROCM_COMGR_ROOT;$ROCM_CMAKE_ROOT;$SETUPTOOLS_ROOT;$PIP_PKG_ROOT"
  -DBUILD_CLIENTS_TESTS=off
  -DHIP_ROOT=$ROCM_HIP_ROOT
  -DGPU_TARGETS="gfx90a;gfx942;gfx1100;gfx1102"
  -DCMAKE_CXX_FLAGS="-I$BOOST_ROOT/include --rocm-path=$ROCM_LLVM_ROOT/amdgcn/bitcode"
  -DROCTX_PATH=$ROCTRACER_ROOT/lib64
  -DPython3_ROOT_DIR="$PYTHON_ROOT"
  -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12"
)
cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
