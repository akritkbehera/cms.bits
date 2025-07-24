package: fmt
version: "10.2.1"
tag: 10.2.1
source: https://github.com/fmtlib/fmt/
build_requires:
- CMake
- gmake
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/
if [ -z "${arch_build_flags:-}" ]; then
  case "$(uname -m)" in
  ppc64le) arch_build_flags="-mcpu=power8 -mtune=power8 --param=l1-cache-size=64 --param=l1-cache-line-size=128 --param=l2-cache-size=512" ;;
  aarch64) arch_build_flags="-march=armv8-a -mno-outline-atomics" ;;
  x86_64) arch_build_flags="" ;;
  *) arch_build_flags="" ;;
  esac
fi

CMAKE_ARGS=(
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT
  -DCMAKE_INSTALL_LIBDIR=lib
  -DBUILD_SHARED_LIBS=TRUE
)

if [[ -n "${arch_build_flags}" ]]; then
  CMAKE_ARGS+=("-DCMAKE_CXX_FLAGS=${arch_build_flags}")
fi

cmake "${CMAKE_ARGS[@]}" .

make ${JOBS:+-j$JOBS}
make install
