package: libnl
version: "3.12.0"
variables:
  version_path: "libnl3_12_0"
sources:
 - git+https://github.com/thom311/libnl.git?obj=main/%(version_path)s&export=libnl&output=/libnl-%(version)s.tar.gz
build_requires:
 - gmake
 - autotools
 - swig
 - flex
 - bison
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"
autoreconf -vif
./configure --prefix="$INSTALLROOT" --disable-static
make ${JOBS:+-j$JOBS} VERBOSE=1
make install
