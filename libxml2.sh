package: libxml2
version: "v2.9.10"
build_requires:
  - autotools
requires:
 - zlib
 - xz
 - gcc
sources:
  - https://gitlab.gnome.org/GNOME/libxml2/-/archive/%(version)s/libxml2-%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./autogen.sh

./configure --disable-static --prefix=$INSTALLROOT \
            --with-zlib="${ZLIB_ROOT}" \
            --with-lzma="${XZ_ROOT}" --without-python

make ${JOBS:+-j$JOBS}
make install
rm -rf ${INSTALLROOT}/lib/pkgconfig
rm -rf ${INSTALLROOT}/lib/*.{l,}a   
