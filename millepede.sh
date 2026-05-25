package: millepede
version: V05-00-00
sources:
 - https://gitlab.desy.de/millepede/millepede-ii/-/archive/%(version)s/%(package)s-ii-%(version)s.tar.gz
build_requires:
 - CMake
requires:
 - root
 - mille
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake_args=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_PREFIX_PATH="${ROOT_ROOT}"
    -DCMAKE_CXX_STANDARD="${CXXSTD:-20}"
    -DLAPACK_OPENBLAS=off
)
cmake "${cmake_args[@]}"
make ${JOBS:+-j$JOBS} -C "$BUILDDIR/build" VERBOSE=1
make -C "$BUILDDIR/build" install PREFIX="$INSTALLROOT"
