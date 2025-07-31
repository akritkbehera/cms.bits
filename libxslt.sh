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


LDFLAGS="-L$LIBXML2_ROOT/lib -lxml2"

aclocal -I config -I "$AUTOTOOLS_ROOT/share/aclocal"
libtoolize --copy --force
autoheader
automake --add-missing --copy
autoconf

export CPPFLAGS="-I${LIBXML2_ROOT}/include/libxml2"
export LDFLAGS="-L${LIBXML2_ROOT}/lib"
export PKG_CONFIG_PATH="${LIBXML2_ROOT}/lib/pkgconfig:${PKG_CONFIG_PATH}"

./configure \
  --prefix="$INSTALLROOT" \
  --disable-silent-rules \
  --with-libxml-prefix="$LIBXML2_ROOT" \
  --without-crypto \
  --without-python

make ${JOBS:+-j${JOBS}}
make install
