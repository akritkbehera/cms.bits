package: eigen
version: "5.0.1"
# cmsdist fetches git+https://gitlab.com/libeigen/eigen.git?tag=5.0.1, but pkgtools ignores
# tag= and builds master HEAD; its "5.0.1" (and eigen-const-scalar-operand.patch) is eigen
# master as of 2026-07-25, not the 5.0.1 release tag. Pin that commit for reproducibility.
variables:
  commit: d53ac33805ba0a23fa139adaf24227fb6707e6fa
sources:
 - https://gitlab.com/libeigen/eigen/-/archive/%(commit)s/eigen-%(commit)s.tar.gz
patches:
 - eigen-const-scalar-operand.patch
build_requires:
 - CMake
# gcc is a runtime dependency: this eigen installs libeigen_blas/libeigen_lapack, which
# link libgfortran, libquadmath and libstdc++ (required by the check_dependencies hook).
requires:
 - gcc
prepend_path:
  PKG_CONFIG_PATH: $EIGEN_ROOT/share/pkgconfig
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DBUILD_TESTING=OFF \
  -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s

make -C "$BUILDDIR/build" install
