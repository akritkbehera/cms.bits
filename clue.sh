package: clue
version: 1.1.3
variables:
  tag: V_1_1_3
sources:
  - https://gitlab.cern.ch/kalos/clue/-/archive/%(tag)s/clue-%(tag)s.tar.gz
requires:
 - alpaka
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
mkdir -p $INSTALLROOT/include
cp -ar clueLib/include $INSTALLROOT/include
