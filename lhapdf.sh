package: lhapdf
version: 6.4.0
variables:
    setsversion: "6.5.1c"
sources:
 - http://www.hepforge.org/archive/lhapdf/LHAPDF-%(version)s.tar.gz
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_15_1_X/g14/lhapdf_makeLinks.file
 - https://lhapdfsets.web.cern.ch/current/MSTW2008nlo68cl.tar.gz
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_15_1_X/g14/lhapdf_pdfsetsindex.file
requires:
 - Python
 - gcc
build_requires:
 - py-cython
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

PYTHON=$(which python3) \
  ./configure --prefix=$INSTALLROOT \
  --enable-python

make all ${JOBS:+-j$JOBS}

make install

mkdir -p $INSTALLROOT/share/LHAPDF

tar -xzf "$SOURCEDIR/${SOURCE2}" \
    --strip-components=1 \
    -C $INSTALLROOT/share/LHAPDF

cp "$SOURCEDIR/${SOURCE1}" "$BUILDDIR/makeLinks"
chmod a+x "$BUILDDIR/makeLinks"
$BUILDDIR/makeLinks %(setsversion)s
rm -f pdsets.index
cp -f "$SOURCEDIR/${SOURCE3}" pdsets.index
cd -

find $INSTALLROOT -name '*.la' -exec rm -f {} \;