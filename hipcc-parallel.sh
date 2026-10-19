package: hipcc-parallel
version: "260921.2"
variables:
  tag: 1eed9c07177d43585d0a5e0b2d4eff4955940346
sources:
 - https://github.com/cms-patatrack/hipcc-parallel/archive/%(tag)s.tar.gz
requires:
 - rocm-hip
---
tar -xzf "$SOURCEDIR/$SOURCE0" --strip-components=1 -C "$BUILDDIR"
mkdir -p "$INSTALLROOT/bin"
install -m 0755 hipcc "$INSTALLROOT/bin/hipcc-parallel"
