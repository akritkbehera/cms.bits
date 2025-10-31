package: dablooms
version: 0.9.1
tag: v%(version)s
source: https://github.com/bitly/dablooms
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

make all

make install prefix=$INSTALLROOT
