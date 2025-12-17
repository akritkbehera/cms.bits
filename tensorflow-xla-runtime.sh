package: tensorflow-xla-runtime
version: 2.12.0
build_requires:
 - CMake
patches:
 - tensorflow-xla-runtime-absl.patch
requires:
 - gcc
 - Python
 - eigen
 - py-tensorflow
 - abseil-cpp
---
cp -r ${PY_TENSORFLOW_ROOT}/lib/python%(python_major_minor)s/site-packages/tensorflow .
patch -p0 < "$SOURCEDIR/$PATCH0"

export CMS_EIGEN_CXX_FLAGS="-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64"

if [ $(uname -m) == "aarch64" ]; then
  export CMS_EIGEN_CXX_FLAGS="-DEIGEN_NEON_GEBP_NR=4 ${CMS_EIGEN_CXX_FLAGS}"
fi

export CPATH="${CPATH}:${EIGEN_ROOT}/include/eigen3"
CXXFLAGS="-fPIC -Wl,-z,defs ${arch_build_flags} ${CMS_EIGEN_CXX_FLAGS} $selected_microarch"

cd tensorflow/xla_aot_runtime_src
find . -type f -path '*/service/cpu/runtime_fork_join.cc' | xargs rm -f
cmake -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DCMAKE_CXX_STANDARD="$CXXSTD" \
  -DCMAKE_PREFIX_PATH="$ABSEIL_CPP_ROOT" \
  -DBUILD_SHARED_LIBS="ON"

make ${JOBS:+-j$JOBS}

mkdir -p "$INSTALLROOT"/lib
mv $BUILDDIR/tensorflow/xla_aot_runtime_src/libtf_xla_runtime.so $INSTALLROOT/lib
