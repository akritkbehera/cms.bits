package: TOPO
version: 5.0.0
variables:
  tag: a0e40c6a4dd9aa2184aaaf5edab6b8d2fb8ebd4d
  smp_flags: ""
sources:
  - https://github.com/cms-hls4ml/TOPO/archive/%(tag)s.tar.gz
build_requires:
 - gmake
requires:
 - gcc
 - hls4mlemulatorextras
 - hls
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS} EMULATOR_EXTRAS=${HLS4MLEMULATOREXTRAS_ROOT} HLS_ROOT=${HLS_ROOT}

make PREFIX=$INSTALLROOT install
