package: xz
version: 5.8.3
requires:
 - gcc
sources:
  - https://tukaani.org/xz/xz-%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure \
    CFLAGS='-fPIC -Ofast' \
    --prefix="$INSTALLROOT" \
    --disable-static \
    --disable-nls \
    --disable-rpath \
    --disable-dependency-tracking \
    --disable-doc

make ${JOBS:+-j $JOBS}
make install

if [ -x "$INSTALLROOT/bin/xz" ]; then
  :
else
  exit 1
fi
