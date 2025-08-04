package: clhep
version: "2.4.7.1"
tag: bfc29493e1b4928b1e6b0dff5f754565bcfd4795
variables:
 github_user: cms-externals
 branch: cms/v%(version)s
sources:
-  git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag_basename)s&export=%(package)s.%(version)s&output=/%(package)s.%(version)s-%(tag_basename)s.tgz
build_requires:
- CMake 
- gmake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

rm -rf ../build
mkdir ../build
cd ../build

cmake_args=(
  -G Ninja \
  -DCLHEP_BUILD_CXXSTD="-std=c++$CXXSTD" \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=$LLVM_BUILD_TYPE
)

cmake "${cmake_args[@]}" ../$PKGNAME

ninja -v ${JOBS:+-j$JOBS} 
ninja install

case $(uname) in Darwin ) so=dylib ;; * ) so=so ;; esac
rm -f $INSTALLROOT/lib/libCLHEP-[A-Z]*-%(version)s.$so
