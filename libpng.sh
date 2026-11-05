package: libpng
version: "1.6.44"
sources:
 - https://github.com/pnggroup/libpng/archive/refs/tags/v%(version)s.tar.gz
build_requires:
  - autotools
  - gmake
requires:
  - gcc
  - zlib
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -fiv

./configure \
  --prefix="$INSTALLROOT" \
  --disable-silent-rules \
  CPPFLAGS="-I${ZLIB_ROOT}/include" \
  LDFLAGS="-L${ZLIB_ROOT}/lib"

make ${JOBS:+-j$JOBS}
make install

# CMSDIST's relocateConfig step materializes this upstream symlink as a file.
# Keep the copied script relocatable while matching that installed layout.
if [ -L "$INSTALLROOT/bin/libpng-config" ]; then
  cp -L -p "$INSTALLROOT/bin/libpng-config" "$INSTALLROOT/bin/libpng-config.tmp"
  mv -f "$INSTALLROOT/bin/libpng-config.tmp" "$INSTALLROOT/bin/libpng-config"
fi

# CMSDIST drops package documentation.
rm -rf "$INSTALLROOT/share"

# Mirror CMSBUILD default archive cleanup for this recipe.
rm -f "$INSTALLROOT"/lib/*.a "$INSTALLROOT"/lib/*.la
