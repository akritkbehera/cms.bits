package: abseil-cpp
version: "20250814.1"
sources:
- https://github.com/abseil/abseil-cpp/archive/%(version)s.tar.gz
build_requires:
- CMake
- gmake
requires:
- gcc
patches:
- abseil-cpp-ubsan.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

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
