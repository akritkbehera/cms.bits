package: utm
version: "%(tag_basename)s"
tag: "utm_0.14.1"
build_requires:
- gmake
requires:
- xerces-c
- boost
- gcc
source: https://gitlab.cern.ch/cms-l1t-utm/utm
patches:
- utm-boost190.patch
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

# Drops -lboost_system from the makefiles: boost has been header-only for it since 1.69.
patch -p1 -d "$BUILDDIR" < "$SOURCEDIR/$PATCH0"

export XERCES_C_BASE=${XERCES_C_ROOT}
export BOOST_BASE=${BOOST_ROOT}
./configure

make ${JOBS:+-j $JOBS} all

make ${JOBS:+-j $JOBS} install
cp -r lib $INSTALLROOT/lib
cp -r include $INSTALLROOT/include
cp -r xsd-type $INSTALLROOT/xsd-type
cp -r menu.xsd $INSTALLROOT/menu.xsd
