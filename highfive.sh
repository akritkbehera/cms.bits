package: highfive
version: "%(tag_basename)s"
tag: v2.10.1
sources:
 - https://github.com/BlueBrain/HighFive/archive/refs/tags/%(tag_basename)s.tar.gz
patches:
 - highfive-boost190.patch
build_requires:
 - CMake
requires:
 - boost
 - hdf5
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

CMAKE_ARGS=(
    -S "$BUILDDIR"
    -B "$BUILDDIR/build"
    -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
    -DCMAKE_BUILD_TYPE=%(cms_build_type)s
    -DHIGHFIVE_EXAMPLES=OFF
    -DHIGHFIVE_UNIT_TESTS=OFF
    -DCMAKE_PREFIX_PATH="${BOOST_ROOT};${HDF5_ROOT}"
)

cmake "${CMAKE_ARGS[@]}"

make -C "$BUILDDIR/build" install VERBOSE=1
