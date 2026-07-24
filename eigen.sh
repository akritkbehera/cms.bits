package: eigen
version: c1d637433e3b3f9012b226c2c9125c494b470ae6
variables:
  tag: b25e86af3379e35cd267d337693684dcdbdfd5d1
  branch: cms/master/%(version)s
  github_user: cms-externals
sources:
 - git+https://github.com/%(github_user)s/eigen-git-mirror.git?obj=%(branch)s/%(tag)s&export=eigen-%(version)s&output=/eigen-%(version)s.tgz
build_requires:
 - CMake
 - gcc
prepend_path:
  PKG_CONFIG_PATH: $EIGEN_ROOT/share/pkgconfig
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DBUILD_TESTING=OFF \
  -DCMAKE_CXX_STANDARD=%(cms_cxx_std)s

make -C "$BUILDDIR/build" install
