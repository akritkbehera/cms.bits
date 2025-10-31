package: mozsearch
version: "20240514"
variables:
 tag: d697005b97f28d493a24887ed25fd2e68839c716
 branch: master
 github_user: mozsearch
sources: 
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
patches:
 - mozsearch-gcc-toolchain.patch
build_requires:
 - gmake
requires:
 - llvm
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 <$SOURCEDIR/$PATCH0

cd clang-plugin
GCC_ROOT=${GCC_ROOT} make ${JOBS:+-j$JOBS} build

mkdir -p $INSTALLROOT/lib64
cp clang-plugin/libclang-index-plugin.so $INSTALLROOT/lib64
