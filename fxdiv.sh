package: fxdiv
version: "2020-04-17"
tag: b408327ac2a15ec3e43352421954f5b1967701d1
sources: 
 - https://github.com/Maratyszcza/FXdiv/archive/%(tag_basename)s.tar.gz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

mkdir -p $INSTALLROOT/include
cp -a include/fxdiv.h     $INSTALLROOT/include/

