package: dcap
version: "2.47.14"
sources:
- https://github.com/dCache/dcap/archive/refs/tags/%(version)s.tar.gz
build_requires:
- autotools
requires:
- zlib
- gcc
- gmake
- libtool
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

if [ -f src/Makefile.am ]; then
    perl -p -i.bak -e 's|^library_includedir.*|library_includedir=\$(includedir)|' src/Makefile.am
    echo "Patched src/Makefile.am"
    diff src/Makefile.am.bak src/Makefile.am || true
else
    echo "Warning: src/Makefile.am not found"
fi

mkdir -p config
aclocal -I config -I "$LIBTOOL_ROOT/share/aclocal"
autoheader
libtoolize --automake
automake --add-missing --copy --foreign
autoconf 
./configure --prefix "$INSTALLROOT" \
    CFLAGS="-I${ZLIB_ROOT}/include -Wno-implicit-function-declaration" \
    LDFLAGS="-L${ZLIB_ROOT}/lib"
make -C src ${JOBS:+-j$JOBS}
make -C src install 
