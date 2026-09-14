package: libffi
version: "v3.5.2"
sources:
  - https://github.com/libffi/libffi/archive/%(version)s.tar.gz
build_requires:
 - autotools
 - gmake
requires:
 - gcc
prepend_path:
  LD_LIBRARY_PATH: $LIBFFI_ROOT/lib64
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Refresh config.guess/config.sub so autoreconf recognizes newer host triples.
CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
rm -f "$BUILDDIR"/config.{sub,guess}
curl -L -k -s -o "$BUILDDIR/config.guess" "$CONFIG_BASE_URL/config.guess"
curl -L -k -s -o "$BUILDDIR/config.sub" "$CONFIG_BASE_URL/config.sub"
chmod +x "$BUILDDIR"/config.{sub,guess}

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
