package: boost
version: "1.91.0"
variables:
  # underscore form for the release-tarball name (boost_1_91_0.tar.gz)
  boost_underscore: "1_91_0"
sources:
  # Upstream switched from the cms-externals git fork to the official release tarballs.
  - https://archives.boost.io/release/%(version)s/source/boost_%(boost_underscore)s.tar.gz
patches:
  - boost-cms-fixes.patch
requires:
  - gcc
  - Python
  - bz2lib
  - zlib
  - openmpi
  - xz
  - zstd
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

# Detect toolset
if [[ "$(uname)" == "Darwin" ]]; then
    TOOLSET=darwin
else
    TOOLSET=gcc
fi

# Bootstrap b2 build tool
pushd "$BUILDDIR/tools/build"
    sh bootstrap.sh "${TOOLSET}"
    mkdir -p ./tmp-boost-build
    ./b2 install --prefix=./tmp-boost-build
    export PATH="${PWD}/tmp-boost-build/bin:${PATH}"
popd

# Configure python and mpi
PYTHONV=$(echo "$PYTHON_VERSION" | sed 's/^v//' | cut -f1,2 -d.)
echo "using mpi ;" >> "$BUILDDIR/user-config.jam"
echo "using python : ${PYTHONV} : ${PYTHON_ROOT}/bin/python3 : ${PYTHON_ROOT}/include/python${PYTHONV} : ${PYTHON_ROOT}/lib ;" >> "$BUILDDIR/user-config.jam"

# Build
b2_args=(
    -q
    -d2
    define=BOOST_FILESYSTEM_DISABLE_STATX
    ${JOBS:+-j$JOBS}
    --build-dir="$BUILDDIR/build-boost"
    --disable-icu
    --without-atomic
    --without-container
    --without-context
    --without-coroutine
    --without-exception
    --without-graph
    --without-graph_parallel
    --without-locale
    --without-log
    --without-math
    --without-random
    --without-wave
    --user-config="$BUILDDIR/user-config.jam"
    toolset="${TOOLSET}"
    link=shared
    threading=multi
    variant=release
    python="${PYTHONV}"
    -sBZIP2_INCLUDE="${BZ2LIB_ROOT}/include"
    -sBZIP2_LIBPATH="${BZ2LIB_ROOT}/lib"
    -sZLIB_INCLUDE="${ZLIB_ROOT}/include"
    -sZLIB_LIBPATH="${ZLIB_ROOT}/lib"
    -sLZMA_INCLUDE="${XZ_ROOT}/include"
    -sLZMA_LIBPATH="${XZ_ROOT}/lib"
    -sZSTD_INCLUDE="${ZSTD_ROOT}/include"
    -sZSTD_LIBPATH="${ZSTD_ROOT}/lib"
    stage
)
b2 "${b2_args[@]}"

# Install libraries, cmake files and headers.
# Use tar to copy so the lib/cmake/ directory hierarchy is preserved (boost's
# *-config.cmake reference siblings via ${CMAKE_CURRENT_LIST_DIR}/../ and break if
# flattened into lib/).
mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/include"
pushd "$BUILDDIR/stage/lib"
  find . -name "*.so*"   -type f | tar cf - -T - | (cd "$INSTALLROOT/lib" && tar xfp -)
  find . -name "*.cmake" -type f | tar cf - -T - | (cd "$INSTALLROOT/lib" && tar xfp -)
popd
pushd "$BUILDDIR"
  find boost -name '*.[hi]*' | tar cf - -T - | (cd "$INSTALLROOT/include" && tar xfp -)
popd

# Relocate the CMake package files (b2 stage bakes build-tree paths into them):
#   1. rewrite the staged build path to the install root
#   2. fix boost's include-dir computation: ${_BOOST_CMAKEDIR}/../../../ overshoots to
#      the parent of the install dir; it must resolve to <prefix>/include
find "$INSTALLROOT/lib/cmake" -name '*.cmake' -print0 | xargs -0 sed -i \
  -e "s#${BUILDDIR}/stage#${INSTALLROOT}#g" \
  -e 's#_BOOST_INCLUDEDIR "${_BOOST_CMAKEDIR}/../../../"#_BOOST_INCLUDEDIR "${_BOOST_CMAKEDIR}/../../include/"#g'

# Create unversioned shared-library symlinks (libboost_x.so.1.80.0 -> libboost_x.so)
for l in $(find "$INSTALLROOT/lib" -name "*.so.*"); do
  ln -sf "$(basename "$l")" "$(echo "$l" | sed -e 's|[.]so[.].*|.so|')"
done

