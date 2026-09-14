package: photospp
version: "3.64"
variables:
  tag: v%(version)s
requires:
 - hepmc
 - hepmc3
 - gcc
sources:
  - https://gitlab.cern.ch/photospp/photospp/-/archive/%(tag)s/photospp-%(tag)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rm -f ./config/config.{sub,guess}

./configure --prefix=$INSTALLROOT --with-hepmc=${HEPMC_ROOT} --with-hepmc3=$HEPMC3_ROOT

make ${JOBS:+-j$JOBS}
make install
ls $INSTALLROOT/lib/
