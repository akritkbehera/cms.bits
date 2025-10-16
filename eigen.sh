package: eigen
version: "%(tag_basename)s"
tag: cms/master/3bb6a48d8c171cf20b5f8e48bfb4e424fbd4f79e
sources:
 - git+https://github.com/cms-externals/eigen-git-mirror.git?obj=cms/master/c1d637433e3b3f9012b226c2c9125c494b470ae6/3cbe8e768c9c51af49d533eee3f3e96fd53e13d7&export=eigen-c1d637433e3b3f9012b226c2c9125c494b470ae6&output=/eigen-c1d637433e3b3f9012b226c2c9125c494b470ae6-3cbe8e768c9c51af49d533eee3f3e96fd53e13d7.tgz
build_requires:
- CMake
env:
  PKG_CONFIG_PATH: EIGEN_ROOT/share/pkgconfig
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir $BUILDROOT/build
cd $BUILDROOT/build

cmake $BUILDDIR -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DBUILD_TESTING=OFF \
  -DCMAKE_CXX_STANDARD=$CXXSTD

make install
