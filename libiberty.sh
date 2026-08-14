package: libiberty
version: "2.43.1"
sources:
 - https://sourceware.org/pub/binutils/releases/binutils-%(version)s.tar.bz2
build_requires:
 - gmake
requires:
 - gcc
---
tar -xjf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Only the libiberty subdirectory is configured/built -- this package ships just the
# static library and its two public headers, not the rest of binutils.
cd "$BUILDDIR/libiberty"
./configure --prefix="$INSTALLROOT" CC="gcc -fPIC" CXX="c++ -fPIC"
make ${JOBS:+-j$JOBS}

# libiberty's own `make install` does not install libiberty.a where consumers look,
# so the artefacts are placed by hand (as the spec does).
mkdir -p "$INSTALLROOT/lib" "$INSTALLROOT/include"
cp "$BUILDDIR/libiberty/libiberty.a" "$INSTALLROOT/lib/"
for h in libiberty.h demangle.h ; do
  cp "$BUILDDIR/include/$h" "$INSTALLROOT/include/$h"
done
