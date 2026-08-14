package: rocm-rocprofiler-systems
version: "7.14"
sources:
  - git+https://github.com/ROCm/rocm-systems.git?obj=release/therock-%(version)s/HEAD&export=rocm-systems&submodules=1&output=/rocm-systems.tar.gz
patches:
  - rocprofiler-systems-elfutils.patch
  - rocprofiler-systems-dyninst-tbb-boost-conflict.patch
build_requires:
  - CMake
  - gmake
  - flex
  - bison
  - libiberty
  - rocm-llvm
  - rocm-cmake
requires:
  - gcc
  - rocm-core
  - rocr-runtime
  - rocprofiler
  - roctracer
  - rocm-hip
  - libxml2
  - libunwind
  - dyninst
  - bz2lib
  - sqlite
  - rocm-rocprofiler-sdk
  - amdsmi
  - zlib
  - rocm-comgr
  - boost
  - TBB
  - json
  - py-pybind11
  - Python
  - elfutils
  - xz
---
# rocm-systems monorepo build (port of cmsdist rocm-rocprofiler-systems.spec, IB/CMSSW_20_1_X/g14).
export ROCM_PROJECT="rocprofiler-systems"
export ROCM_PRE_BUILD_HOOK='
patch -p1 -d "$BUILDDIR/rocm-systems" < "$SOURCEDIR/rocprofiler-systems-elfutils.patch"
patch -p1 -d "$BUILDDIR/rocm-systems" < "$SOURCEDIR/rocprofiler-systems-dyninst-tbb-boost-conflict.patch"
export CPPFLAGS="-I${BZ2LIB_ROOT}/include"
export LDFLAGS="-L${BZ2LIB_ROOT}/lib"
export PKG_CONFIG_PATH="${ELFUTILS_ROOT}/lib/pkgconfig:/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
# elf-bfd.h must come after elfutils/libdw.h, else the two disagree on the Elf types.
perl -i -0pe "s/#include <elf-bfd\.h>\n#include <elfutils\/libdw\.h>/#include <elfutils\/libdw.h>\n#include <elf-bfd.h>/" "$BUILDDIR/rocm-systems/projects/rocprofiler-systems/source/lib/binary/symbol.cpp"
'
export ROCM_CMAKE_EXTRA_ARGS='-DCMAKE_PREFIX_PATH="${GCC_ROOT};${ROCM_CORE_ROOT};${ROCR_RUNTIME_ROOT};${ROCM_HIP_ROOT};${ROCM_LLVM_ROOT};${ROCM_COMGR_ROOT};${ROCPROFILER_ROOT};${ROCTRACER_ROOT};${ROCM_ROCPROFILER_SDK_ROOT};${AMDSMI_ROOT};${DYNINST_ROOT};${BOOST_ROOT};${TBB_ROOT};${JSON_ROOT};${SQLITE_ROOT};${LIBUNWIND_ROOT};${LIBXML2_ROOT};${ZLIB_ROOT};${BZ2LIB_ROOT};${PY_PYBIND11_ROOT};${LIBIBERTY_ROOT};${FLEX_ROOT};${BISON_ROOT};${ELFUTILS_ROOT};${XZ_ROOT}" -DTBB_ROOT_DIR="${TBB_ROOT}" -DROCPROFSYS_USE_BFD=ON -DROCPROFSYS_USE_PYTHON=ON -DROCPROFSYS_BUILD_PYTHON=OFF -DROCPROFSYS_BUILD_DYNINST=OFF -DROCPROFSYS_BUILD_TBB=OFF -DROCPROFSYS_BUILD_LIBUNWIND=OFF -DROCPROFSYS_BUILD_BOOST=OFF -DROCPROFSYS_BUILD_LIBIBERTY=OFF -DROCPROFSYS_BUILD_ELFUTILS=OFF -DElfUtils_ROOT_DIR="$ELFUTILS_ROOT" -DElfUtils_INCLUDEDIR="$ELFUTILS_ROOT/include" -DElfUtils_LIBRARYDIR="$ELFUTILS_ROOT/lib" -DROCPROFILER_BUILD_SQLITE3=OFF -DROCPROFSYS_BUILD_NLOHMANN_JSON=OFF -DROCPROFSYS_BUILD_EXAMPLES=OFF -DROCPROFSYS_BUILD_TESTING=OFF -DCMAKE_FIND_DEBUG_MODE=OFF -DROCPROFSYS_USE_PAPI=OFF -DPython3_ROOT_DIR="$PYTHON_ROOT" -DPython3_FIND_VIRTUALENV=STANDARD -DPython3_EXECUTABLE="$PYTHON_ROOT/bin/python3.12" -DPython3_INCLUDE_DIR="$PYTHON_ROOT/include/python3.12" -DPython3_LIBRARY="$PYTHON_ROOT/lib/libpython3.12.so"'
#!include <rocm-systems-build.sh>
