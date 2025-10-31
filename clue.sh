package: clue
version: 1.0.0
tag: V_1_0_0
source: https://gitlab.cern.ch/kalos/clue.git
requires:
 - alpaka
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
mkdir -p $INSTALLROOT/include
cp -ar clueLib/include $INSTALLROOT/include
