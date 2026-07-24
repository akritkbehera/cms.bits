package: lhapdf
version: 6.4.0
variables:
    setsversion: "6.5.1c"
sources:
 - https://lhapdf.hepforge.org/downloads/?f=LHAPDF-%(version)s.tar.gz
 - https://lhapdfsets.web.cern.ch/current/MSTW2008nlo68cl.tar.gz
 - file://lhapdf_makeLinks.file
 - file://lhapdf_pdfsetsindex.file
build_requires:
 - py-cython
requires:
 - Python
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

PYTHON=$(which python3) \
  ./configure --prefix=$INSTALLROOT \
  --enable-python

# Delete wrappers/python/lhapdf.cpp and re-generate with newer cython
rm -f wrappers/python/lhapdf.cpp

sed -i '/yaml-cpp\/null.h/a #include <cstdint>' src/yamlcpp/emitterutils.cpp

make all ${JOBS:+-j$JOBS}
make install

mkdir -p $INSTALLROOT/share/LHAPDF
tar -xzf "$SOURCEDIR/${SOURCE1}" \
    -C $INSTALLROOT/share/LHAPDF
cd $INSTALLROOT/share/LHAPDF
cp "$SOURCEDIR/${SOURCE2}" "$BUILDDIR/makeLinks"
chmod a+x "$BUILDDIR/makeLinks"
$BUILDDIR/makeLinks %(setsversion)s
rm -f pdfsets.index
cp -f "$SOURCEDIR/${SOURCE3}" pdfsets.index
cd -

# Remove all libtool archives and docs
find $INSTALLROOT -name '*.la' -exec rm -f {} \;
rm -rf $INSTALLROOT/share/doc
