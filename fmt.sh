package: fmt
version: "10.2.1"
tag: 10.2.1
source: https://github.com/fmtlib/fmt/
build_requires:
- CMake
- gmake
requires:
- gcc
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
  -S "$BUILDDIR"
  -B "$BUILDDIR/build"
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
  -DCMAKE_INSTALL_LIBDIR=lib
  -DBUILD_SHARED_LIBS=TRUE
)

if [[ -n "${arch_build_flags}" ]]; then
  CMAKE_ARGS+=("-DCMAKE_CXX_FLAGS=${arch_build_flags}")
fi
if [[ "$VERBOSE" == "1" ]]; then
  CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake "${CMAKE_ARGS[@]}"
make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS}
make -C "$BUILDDIR/build" install
