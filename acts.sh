package: acts
version: "v44.0.1"
variables:
  tag:         30fb4ea
  branch:      cms/%(version)s
  github_user: cms-externals
sources:
  - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - boost
  - dd4hep
  - eigen
  - expat
  - fastjet
  - geant4
  - clhep
  - xerces-c
  - zlib
  - json
  - Python
  - py-pybind11
  - ROOT
  - cuda
  - rocm
  - hepmc3
  - TBB
  - bz2lib
  - zstd
  - xz
prepend_path:
  PYTHON3PATH: "%(root_dir)s/python"
---
#!include <compilation-flags.file>
#!include <compilation-flags-lto.file>
#!include <microarch-flags.file>
#!include <cuda-flags.file>
#!include <rocm-flags.file>

export build_test="1"

# Eigen build flags (from the scram-tools eigen env / defaults)
export CMS_EIGEN_CXX_FLAGS="-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64"

# Detect CUDA and ROCm
cuda_enabled="OFF"; [ -n "$CUDA_ROOT" ] && cuda_enabled="ON"
rocm_enabled="OFF"; [ -n "$ROCM_ROOT" ] && rocm_enabled="ON"

# HIP/ROCm support is not yet working correctly
rocm_enabled="OFF"

# Unpack the source tarball
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Notes:
#   - gcc-ar and gcc-ranlib are needed to build static libraries with LTO support.
#   - building with RPATH enabled is necessary to build and run the tests;
#     CMAKE_SKIP_INSTALL_RPATH strips the RPATH information after installing the libraries.
cmake_args=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    "-DCMAKE_PREFIX_PATH=$GCC_ROOT;$BOOST_ROOT;$BZ2LIB_ROOT;$CLHEP_ROOT;$DD4HEP_ROOT;$EIGEN_ROOT;$EXPAT_ROOT;$FASTJET_ROOT;$GEANT4_ROOT;$HEPMC3_ROOT;$JSON_ROOT;$PY_PYBIND11_ROOT;$PYTHON_ROOT;$ROOT_ROOT;$TBB_ROOT;$XERCES_C_ROOT;$XZ_ROOT;$ZLIB_ROOT;$ZSTD_ROOT;$CUDA_ROOT;$ROCM_ROOT"
    "-DCMAKE_CXX_COMPILER=$GCC_ROOT/bin/g++"
    "-DCMAKE_CXX_STANDARD=$CXXSTD"
    "-DCMAKE_CXX_FLAGS=-fPIC $CMS_EIGEN_CXX_FLAGS ${arch_build_flags} $selected_microarch ${lto_build_flags}"
    "-DCMAKE_AR=$GCC_ROOT/bin/gcc-ar"
    "-DCMAKE_RANLIB=$GCC_ROOT/bin/gcc-ranlib"
    "-DCMAKE_BUILD_TYPE=%(cms_build_type)s"
    "-DCMAKE_INSTALL_PREFIX=$INSTALLROOT"
    "-DCMAKE_SKIP_INSTALL_RPATH=ON"
    "-DBUILD_SHARED_LIBS=ON"
    "-DACTS_NLOHMANNJSON_SOURCE="
    "-DACTS_USE_SYSTEM_NLOHMANN_JSON=ON"
    "-DACTS_USE_SYSTEM_PYBIND11=ON"
    "-DACTS_BUILD_PLUGIN_ACTSVG=ON"
    "-DACTS_BUILD_PLUGIN_FASTJET=ON"
    "-DACTS_BUILD_PLUGIN_JSON=ON"
    "-DACTS_BUILD_PLUGIN_ROOT=ON"
    "-DACTS_BUILD_PLUGIN_DD4HEP=ON"
    "-DACTS_BUILD_PLUGIN_GEANT4=ON"
    "-DACTS_BUILD_PLUGIN_TRACCC=ON"
    "-DACTS_ENABLE_LOG_FAILURE_THRESHOLD=ON"
    "-DACTSVG_USE_SYSTEM_PYBIND11=ON"
    "-DCOVFIE_PLATFORM_CPU=ON"
    "-DCOVFIE_PLATFORM_CUDA=${cuda_enabled}"
    "-DCOVFIE_PLATFORM_HIP=${rocm_enabled}"
    "-DDETRAY_SETUP_NLOHMANN=ON"
    "-DDETRAY_USE_SYSTEM_NLOHMANN=ON"
    "-DDETRAY_BUILD_HOST=ON"
    "-DDETRAY_BUILD_CUDA=${cuda_enabled}"
    "-DDETRAY_BUILD_HIP=${rocm_enabled}"
    "-DTRACCC_BUILD_CUDA=${cuda_enabled}"
    "-DTRACCC_BUILD_HIP=${rocm_enabled}"
    "-DTRACCC_SETUP_THRUST=${cuda_enabled}"
    "-DTRACCC_SETUP_ROCTHRUST=${rocm_enabled}"
    "-DTRACCC_USE_SYSTEM_THRUST=${cuda_enabled}"
    "-DTRACCC_USE_SYSTEM_ROCTHRUST=${rocm_enabled}"
    "-DVECMEM_BUILD_CUDA_LIBRARY=${cuda_enabled}"
    "-DVECMEM_BUILD_HIP_LIBRARY=${rocm_enabled}"
)

# CUDA-specific options
if [ "$cuda_enabled" = "ON" ]; then
    cmake_args+=(
        "-DCMAKE_CUDA_ARCHITECTURES=$(echo ${cuda_arch} | sed -e 's/ \+/;/g')"
        "-DCMAKE_CUDA_FLAGS=-Wno-deprecated-gpu-targets"
    )
fi

# ROCm/HIP-specific options
if [ "$rocm_enabled" = "ON" ]; then
    cmake_args+=(
        "-DCMAKE_HIP_ARCHITECTURES=$(echo ${rocm_archs} | sed -e 's/ \+/;/g')"
        "-DAMDGPU_TARGETS=$(echo ${rocm_archs} | sed -e 's/ \+/;/g')"
    )
fi

# These are only used to build the examples and unit tests
if [ "$build_test" = "1" ]; then
    cmake_args+=(
        "-DACTS_BUILD_UNITTESTS=ON"
        "-DACTS_BUILD_INTEGRATIONTESTS=ON"
        "-DPython_EXECUTABLE=$(which python3)"
        "-DACTS_BUILD_EXAMPLES_PYTHON_BINDINGS=ON"
        "-DTRACCC_BUILD_TESTING=ON"
    )
fi

cmake "${cmake_args[@]}" -L

make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1

# remove the scripts used to set the Acts environment variables
rm -f "$INSTALLROOT/bin/this_acts.sh"
rm -f "$INSTALLROOT/bin/this_acts_withdeps.sh"
rm -f "$INSTALLROOT/python/setup.sh"
