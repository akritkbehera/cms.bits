package: cms-recipe-tools
version: main
variables:
  tag: f904bda8e6848b2e10ddc2c72a8bf1a43c9b0dec
sources:
  - https://github.com/akritkbehera/bits-recipe-tools/archive/%(tag)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p $INSTALLROOT/bin
install $BUILDDIR/*Recipe $INSTALLROOT
install $BUILDDIR/bits-* $INSTALLROOT/bin
