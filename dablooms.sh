package: dablooms
version: 0.9.1
variables:
  tag: v%(version)s
sources:
  - https://github.com/bitly/dablooms/archive/%(tag)s.tar.gz
build_requires:
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make all

make install prefix=$INSTALLROOT
