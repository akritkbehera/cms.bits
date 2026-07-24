package: opencv
version: 4.9.0
variables:
  branch: master
  github_user: opencv
sources:
- git+https://github.com/%(github_user)s/opencv.git?obj=%(branch)s/%(version)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(version)s.tgz
build_requires:
- CMake
- ninja
requires:
- gcc
- Python
- py-numpy
- libpng
- libjpeg-turbo
- libtiff
- zlib
- eigen
- OpenBLAS
prepend_path:
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
# Eigen build flags (from the scram-tools eigen env)
export CMS_EIGEN_CXX_FLAGS="-DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64"
if [ "$(uname -m)" = "aarch64" ]; then
  export CMS_EIGEN_CXX_FLAGS="-DEIGEN_NEON_GEBP_NR=4 ${CMS_EIGEN_CXX_FLAGS}"
fi

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake_args=(
  -G Ninja
  -S "$BUILDDIR"
  -B "$BUILDDIR/build"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s
  -DCMAKE_INSTALL_LIBDIR=lib
  -DWITH_EIGEN=ON
  -DBUILD_EXAMPLES=OFF
  -DWITH_QT=OFF
  -DWITH_GTK=OFF
  -DPYTHON3_EXECUTABLE:FILEPATH="${PYTHON_ROOT}/bin/python3"
  -DPYTHON3_INCLUDE_DIR:PATH="${PYTHON_ROOT}/include/python${PYTHON_MAJOR_MINOR_VERSION}"
  -DPYTHON3_LIBRARY:FILEPATH="${PYTHON_ROOT}/lib/libpython${PYTHON_MAJOR_MINOR_VERSION}.so"
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s
  -DCMAKE_CXX_FLAGS="$CMS_EIGEN_CXX_FLAGS ${selected_microarch}"
  -DCMAKE_PREFIX_PATH="${LIBPNG_ROOT};${LIBTIFF_ROOT};${LIBJPEG_TURBO_ROOT};${ZLIB_ROOT};${PYTHON_ROOT};${PY_NUMPY_ROOT};${EIGEN_ROOT};${OPENBLAS_ROOT}"
)

cmake "${cmake_args[@]}"

ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS}
ninja -C "$BUILDDIR/build" -v ${JOBS:+-j$JOBS} install
