package: re2c
version: "1.0.1"
sources:
  - https://github.com/skvadrik/re2c/archive/%(version)s.tar.gz
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
cd $PKGNAME
autoreconf -i -W all
./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j $JOBS}
make install