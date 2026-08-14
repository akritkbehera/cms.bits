package: ktjet
version: "1.06"
sources:
 - https://ktjet.hepforge.org/downloads/?f=KtJet-%(version)s.tar.gz
patches:
 - ktjet-1.0.6-nobanner.patch
requires:
 - clhep
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 <$SOURCEDIR/$PATCH0

CPPFLAGS=" -DKTDOUBLEPRECISION -fPIC" ./configure --with-clhep=$CLHEP_ROOT --prefix=$INSTALLROOT

make install
