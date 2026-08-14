package: c-ares
version: "1_15_0"
sources:
 - https://github.com/c-ares/c-ares/archive/cares-%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMAKE_ARGS=(
    -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
)

if [[ "$VERBOSE" == "1" ]]; then
    CMAKE_ARGS+=(-DCMAKE_VERBOSE_MAKEFILE=ON)
fi

cmake -S "$BUILDDIR" -B "$BUILDDIR" "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR" ${JOBS:+-j "$JOBS"} ${VERBOSE:+VERBOSE=1}
make -C "$BUILDDIR" install
