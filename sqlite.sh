package: sqlite
version: "3.48.0"
sources:
 - https://www.sqlite.org/2025/sqlite-autoconf-3480000.tar.gz
build_requires:
 - gmake
requires:
 - gcc
 - zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMS_BITS_MARCH=$(gcc -dumpmachine)

cd "$BUILDDIR"
CFLAGS=-I${ZLIB_ROOT}/include LDFLAGS=-L${ZLIB_ROOT}/lib \
./configure --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" --prefix=$INSTALLROOT \
            --disable-static --disable-dependency-tracking

make ${JOBS:+-j$JOBS}
make install
rm -rf $INSTALLROOT/lib/pkgconfig
