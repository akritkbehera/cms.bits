package: xz
version: 5.8.3
variables:
  tag: v%(version)s
build_requires:
 - autotools
requires:
 - gcc
sources:
  - https://github.com/tukaani-project/xz/archive/%(tag)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./autogen.sh --no-po4a

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
