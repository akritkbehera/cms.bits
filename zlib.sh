package: zlib
version: "1.3.2"
variables:
  tag: v%(version)s
sources:
  - https://github.com/madler/zlib/archive/%(tag)s.tar.gz
build_requires:
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
CONF_FLAGS="-fPIC -O3 -DUSE_MMAP -DUNALIGNED_OK -D_LARGEFILE64_SOURCE=1 -D_DEFAULT_SOURCE"
CFLAGS="$CONF_FLAGS" ./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j$JOBS}
make install
