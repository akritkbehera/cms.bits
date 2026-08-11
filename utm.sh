package: utm
version: "0.14.1"
build_requires:
- gmake
requires:
- xerces-c
- boost
- gcc
sources: 
- https://gitlab.cern.ch/cms-l1t-utm/utm/-/archive/utm_%(version)s/utm-utm_%(version)s.tar.gz
patches:
- utm-boost190.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

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
