package: xrdcl-record
version: "5.4.2"
build_requires:
- CMake
- gmake
requires:
- XRootD
- gcc
sources:
- https://github.com/xrootd/xrdcl-record/archive/refs/tags/v%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_PREFIX_PATH="${XROOTD_ROOT}" \
  -DCMAKE_VERBOSE=1 \
  -DCMAKE_CXX_FLAGS="-L${XROOTD_ROOT}/lib64"

gmake -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
gmake -C "$BUILDDIR/build" install
