package: libxslt
version: "1.1.42"
variables:
  tag: v%(version)s
sources:
  - https://gitlab.gnome.org/GNOME/libxslt/-/archive/%(tag)s/libxslt-%(tag)s.tar.gz
build_requires:
- autotools
requires:
- gcc
- libxml2
- pkg-config
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

export CPPFLAGS="-I${LIBXML2_ROOT}/include/libxml2"
export LDFLAGS="-L${LIBXML2_ROOT}/lib"
export PKG_CONFIG_PATH="${LIBXML2_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"

export LIBS="-lxml2"

./autogen.sh \
--prefix=$INSTALLROOT \
--disable-silent-rules \
--with-libxml-prefix=$LIBXML2_ROOT \
--with-libxml-include-prefix=$LIBXML2_ROOT/include/libxml2 \
--with-libxml-libs-prefix=$LIBXML2_ROOT/lib \
--without-crypto --without-python

make ${JOBS:+-j${JOBS}}
make install
