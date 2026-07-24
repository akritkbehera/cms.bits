package: libffi
version: "%(tag_basename)s"
tag: v3.5.2
source: https://github.com/libffi/libffi
build_requires:
 - autotools
 - gmake
requires:
 - gcc
prepend_path:
  LD_LIBRARY_PATH: $LIBFFI_ROOT/lib64
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' \
      "$SOURCEDIR"/ "$BUILDDIR"/

autoreconf -fiv

CFLAGS="-Wno-deprecated-declarations" \
  ./configure \
  --prefix="$INSTALLROOT" \
  --enable-portable-binary \
  --disable-dependency-tracking \
  --disable-static \
  --disable-docs

make ${JOBS:+-j$JOBS}
make ${JOBS:+-j$JOBS} install

rm -rf "${INSTALLROOT}/lib"
rm -rf ${INSTALLROOT}/lib64/*.la
