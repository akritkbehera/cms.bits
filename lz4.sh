package: lz4
version: "1.10.0"
sources:
  - https://github.com/lz4/lz4/archive/v%(version)s.tar.gz
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

# Mirror CMSBUILD default archive cleanup for this recipe.
rm -f "$INSTALLROOT"/lib/*.a "$INSTALLROOT"/lib/*.la
