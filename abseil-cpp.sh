package: abseil-cpp
version: "%(tag_basename)s"
tag: "20230802.3"
source: https://github.com/abseil/abseil-cpp
build_requires:
- CMake
- gmake
requires:
- gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

CMAKE_ARGS=(
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_CXX_STANDARD="%(cms_cxx_std)s"
    -DCMAKE_INSTALL_LIBDIR=lib
    -DBUILD_TESTING=OFF
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
)
if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake -S "$BUILDDIR" -B "$BUILDDIR" "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR" ${JOBS:+-j "$JOBS"} ${VERBOSE:+VERBOSE=1}
make -C "$BUILDDIR" install
