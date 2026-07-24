package: photospp
version: "3.64"
tag: v%(version)s
requires:
 - hepmc
 - hepmc3
 - gcc
source: https://gitlab.cern.ch/photospp/photospp.git
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

rm -f ./config/config.{sub,guess}

./configure --prefix=$INSTALLROOT --with-hepmc=${HEPMC_ROOT} --with-hepmc3=$HEPMC3_ROOT

make ${JOBS:+-j$JOBS}
make install
ls $INSTALLROOT/lib/
