package: clue
version: 1.1.3
tag: V_1_1_3
source: https://gitlab.cern.ch/kalos/clue.git
requires:
 - alpaka
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
mkdir -p $INSTALLROOT/include
cp -ar clueLib/include $INSTALLROOT/include
