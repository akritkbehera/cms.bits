package: starlight
version: "r193"
variables:
    branch: cms/%%(version)s
    github_user: "cms-externals"
    tag: e1a5d073144c199aa97d40ff8cbb570b5dc5ed33
sources:
  - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
patches:
  - starlight-r193-allow-setting-CMAKE_CXX_FLAGS.patch
requires:
 - gcc
 - clhep
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
rm -rf ../build && mkdir ../build && cd ../build

export CLHEP_PARAM_PATH=${CLHEP_ROOT}
export CXXFLAGS="-Wno-error=deprecated-declarations -Wno-error=deprecated-copy -Wno-error=maybe-uninitialized -Wno-error=unused-but-set-variable -std=c++$CXXSTD"

cmake $BUILDDIR \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DENABLE_CLHEP=ON

make ${JOBS:+-j $JOBS} VERBOSE=1
make install VERBOSE=1

rm -rf $INSTALLROOT/lib/archive