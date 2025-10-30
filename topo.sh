package: TOPO
version: 0.1.0
variables:
  smp_flags: ""
tag: 1e9a692ccfa92cee5a87bbc94eb902b9f560870b
source: https://github.com/cms-hls4ml/TOPO.git
requires:
 - gcc
 - gmake
 - hls4mlemulatorextras
 - hls

---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

make ${JOBS:+-j$JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}

make PREFIX=$INSTALLROOT install
