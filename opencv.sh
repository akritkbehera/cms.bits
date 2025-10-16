package: opencv
version: 4.9.0
sources:
- https://github.com/opencv/opencv/archive/refs/tags/%(version)s.tar.gz
build_requires:
- CMake
- ninja
requires:
- Python
- py-numpy
- libpng
- libjpeg-turbo
- libtiff
- zlib
- eigen
- OpenBLAS
- gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

mkdir $BUILDROOT/build
cd $BUILDROOT/build
CMS_EIGEN_CXX_FLAGS="-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64"
cmake_args=(
  -G Ninja \
  -DCLHEP_BUILD_CXXSTD="-std=c++$CXXSTD" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=$LLVM_BUILD_TYPE \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DWITH_EIGEN=ON \
  -DWITH_EXAMPLES=OFF \
  -DWITH_QT=OFF \
  -DWITH_GTK=OFF \
  -DPYTHON3_EXECUTABLE:FILEPATH="${PYTHON_ROOT}/bin/python" \
  -DPYTHON3_INCLUDE_DIR:PATH="${PYTHON_ROOT}/include/python*/" \
  -DPYTHON3_LIBRARY:FILEPATH="${PYTHON_ROOT}/lib/libpython*.*.so" \
  -DCMAKE_PREFIX_PATH="${LIBPNG_ROOT};${LIBTIFF_ROOT};${LIBJPEG_TURBO_ROOT};${ZLIB_ROOT};${PYTHON3_ROOT};${PY2_NUMPY_ROOT};${PY3_NUMPY_ROOT};${EIGEN_ROOT};${OPENBLAS_ROOT}"
)

cmake "${cmake_args[@]}" $BUILDDIR

ninja -v ${JOBS:+-j$JOBS} 
ninja install
