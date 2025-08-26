package: opencv
version: v"%(tag_basename)s"
tag: 4.9.0
source: https://github.com/opencv/opencv
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
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

rm -rf ../build
mkdir ../build
cd ../build

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

cmake "${cmake_args[@]}" ../$PKGNAME

ninja -v ${JOBS:+-j$JOBS} 
ninja install