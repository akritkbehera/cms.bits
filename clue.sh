package: clue
version: 1.0.0
variables:
 commit: "1_0_0"
sources:
 - https://gitlab.cern.ch/kalos/%(package)s/-/archive/%(commit)s/%(package)s-%(commit)s.tar.gz
requires:
 - alpaka
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p $INSTALLROOT/include
cp -ar clueLib/include $INSTALLROOT/include
