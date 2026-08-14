package: db6
version: "%(tag_basename)s"
tag: 6.2.32
build_requires:
 - gmake
requires:
 - gcc
sources:
- http://cmsrep.cern.ch/cmssw/download/db-%(tag_basename)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CMS_BITS_MARCH=$(gcc -dumpmachine)

mkdir -p "$BUILDDIR/obj"
cd "$BUILDDIR/obj"

CFLAGS="-Wno-incompatible-pointer-types" \
../dist/configure \
    --prefix="$INSTALLROOT" \
    --build="$CMS_BITS_MARCH" --host="$CMS_BITS_MARCH" \
    --disable-java \
    --disable-tcl \
    --disable-static

make ${JOBS:+-j$JOBS}
make install
