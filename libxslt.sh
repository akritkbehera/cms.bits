package: libxslt
version: "v%(tag_basename)s"
tag: 1.1.42
sources:
- https://gitlab.gnome.org/GNOME/libxslt/-/archive/v%(tag_basename)s/libxslt-v%(tag_basename)s.tar.gz
build_requires:
- autotools
requires:
- gcc
- libxml2
- pkg-config
---
tar -xzf "$SOURCEDIR/$SOURCE0" \
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
--without-crypto --without-python

make ${JOBS:+-j${JOBS}}
make install