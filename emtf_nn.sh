package: EMTF_NN
version: 1.0.2
variables:
  tag: v%(version)s
sources:
  - https://github.com/cms-hls4ml/EMTF_NN/archive/%(tag)s.tar.gz
requires:
 - gcc
 - hls4mlemulatorextras
 - hls
build_requires:
 - gmake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j $JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}
make PREFIX=$INSTALLROOT install
