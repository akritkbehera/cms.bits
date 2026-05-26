package: lhapdf
version: 6.4.0
variables:
    setsversion: "6.5.1c"
sources:
 - http://www.hepforge.org/archive/lhapdf/LHAPDF-%(version)s.tar.gz
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/lhapdf_makeLinks.file
 - https://lhapdf.hepforge.org/downloads?f=pdfsets/v6.backup/6.1/MSTW2008nlo68cl.tar.gz
 - https://raw.githubusercontent.com/cms-sw/cmsdist/refs/heads/IB/CMSSW_17_0_X/g14/lhapdf_pdfsetsindex.file
requires:
 - Python
 - gcc
build_requires:
 - py-cython
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"

PYTHON=$(which python3) \
  ./configure --prefix="$INSTALLROOT" \
  --enable-python

rm -f wrappers/python/lhapdf.cpp

sed -i '/yaml-cpp\/null.h/a #include <cstdint>' src/yamlcpp/emitterutils.cpp

make all ${JOBS:+-j$JOBS}
make install

mkdir -p "$INSTALLROOT/share/LHAPDF"
cd "$INSTALLROOT/share/LHAPDF"

cp "$SOURCEDIR/${SOURCE2}" .
tar -xzf MSTW2008nlo68cl.tar.gz
rm -f MSTW2008nlo68cl.tar.gz

chmod a+x "$SOURCEDIR/${SOURCE1}"
"$SOURCEDIR/${SOURCE1}" %(setsversion)s
rm -f pdfsets.index
cp -f "$SOURCEDIR/${SOURCE3}" pdfsets.index
cd -

rm -rf "$INSTALLROOT/share/doc"
find "$INSTALLROOT" -name '*.la' -exec rm -f {} \;

