package: lz4
version: "v1.9.2"
sources:
  - https://github.com/lz4/lz4/archive/%(version)s.tar.gz
build_requires:
  - gmake
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS}
make install PREFIX=$INSTALLROOT