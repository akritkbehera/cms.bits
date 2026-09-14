package: isal
version: "v2.30.0"
sources:
  - https://github.com/intel/isa-l/archive/%(version)s.tar.gz
build_requires:
 - nasm
 - autotools
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./autogen.sh
./configure --prefix=$INSTALLROOT --with-pic

make ${JOBS:+-j$JOBS}
make install