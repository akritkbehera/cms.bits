package: cmssw-wm-tools
version: "250417"
tag: cd271d3796bfd8d0eff6500f801a4367bfd1b5dc
source: https://github.com/cms-sw/cmssw-wm-tools
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

rsync -a $BUILDROOT/$PKGNAME/ $INSTALLROOT/
