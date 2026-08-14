package: XRootD
version: "6.0.2"
sources:
  - https://github.com/xrootd/xrootd/releases/download/v%(version)s/xrootd-%(version)s.tar.gz
requires:
  - zlib
  - libuuid
  - curl
  - davix
  - Python
  - setuptools
  - libxml2
  - isal
  - libzip
  - pip
  - gcc
build_requires:
  - CMake
  - gmake
  - autotools
  - pip
prepend_path:
  LD_LIBRARY_PATH: $XROOTD_ROOT/lib64
  PYTHON3PATH: "%(root_dir)s/${PYTHON3_LIB_SITE_PACKAGES}"
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sed -i \
  -e 's|^ *check_library_exists("uuid" "uuid_generate_random".*$|set(_have_libuuid True)|' \
  "$BUILDDIR/cmake/Findlibuuid.cmake"

unset PIP_ROOT
cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX=${INSTALLROOT} \
  -DCMAKE_BUILD_TYPE=%(cms_build_type)s \
  -DFORCE_ENABLED=ON \
  -DENABLE_FUSE=FALSE \
  -DENABLE_VOMS=FALSE \
  -DXRDCL_ONLY=TRUE \
  -DENABLE_KRB5=TRUE \
  -DENABLE_READLINE=TRUE \
  -DCMAKE_SKIP_RPATH=TRUE \
  -DENABLE_PYTHON=TRUE \
  -DENABLE_HTTP=TRUE \
  -DENABLE_XRDEC=TRUE \
  -DXRD_PYTHON_REQ_VERSION=3 \
  -DPIP_OPTIONS="--verbose" \
  -DCMAKE_CXX_FLAGS="-I${LIBUUID_ROOT}/include" \
  -DCMAKE_SHARED_LINKER_FLAGS="-L${LIBUUID_ROOT}/lib64" \
  -DCMAKE_PREFIX_PATH="$CURL_ROOT;$ZLIB_ROOT;$EXPAT_ROOT;$BZ2LIB_ROOT;$DAVIX_ROOT;$PIP_ROOT;$LIBZIP_ROOT"

make -C "$BUILDDIR/build" ${JOBS:+-j $JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install VERBOSE=1
