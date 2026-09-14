package: file-bootstrap
version: "5.46"
variables:
  tag: FILE5_46
sources:
  - https://github.com/file/file/archive/%(tag)s.tar.gz
requires:
 - autotools
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -fiv
./configure --prefix=$INSTALLROOT
make
make install
