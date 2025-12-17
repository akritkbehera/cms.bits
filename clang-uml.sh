package: clang-uml
version: 0.5.2
variables:
 tag: cd6dce2b0b34d55534d3de512ab088b9ad71bc76
 branch: master
 github_user: bkryza
sources:
 - git+https://github.com/%(github_user)s/clang-uml.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
 - CMake
 - ninja
requires:
 - yaml-cpp
 - llvm
 - zlib
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -rf ../build; mkdir ../build; cd ../build

args=(
  "$BUILDDIR"
  -G Ninja
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
  -DCMAKE_BUILD_TYPE=Release
  -DGIT_VERSION="$PKGVERSION"
  -DCMAKE_PREFIX_PATH="${YAML_CPP_ROOT}/lib64/cmake/yaml-cpp;${ZLIB_ROOT}"
)

if [ "$(uname -m)" = "aarch64" ]; then
  args+=(-DCMAKE_CXX_FLAGS="-Wno-sign-compare")
fi

cmake "${args[@]}"

ninja -v ${JOBS:+-j$JOBS}
ninja -v ${JOBS:+-j$JOBS} install
