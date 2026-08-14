package: mille
version: V01-00-00
sources:
  - https://gitlab.desy.de/millepede/Mille/-/archive/%(version)s/mille-%(version)s.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - gcc
  - zlib
  - ROOT
prepend_path:
  PYTHON3PATH: "%(root_dir)s/python"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake_args=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_PREFIX_PATH="${ZLIB_ROOT};${ROOT_ROOT}"
    # Without this CMake picks rocm-llvm's flang, which rejects the gfortran-style driver
    # arguments it is invoked with and fails the compiler test.
    -DCMAKE_Fortran_COMPILER="${GCC_ROOT}/bin/gfortran"
    -DCMAKE_CXX_STANDARD="%(cms_cxx_std)s"
)
cmake "${cmake_args[@]}"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" VERBOSE=1
make -C "$BUILDDIR/build" install
