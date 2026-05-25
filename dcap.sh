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
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

perl -p -i -e 's|^library_includedir.*|library_includedir=\$(includedir)|' src/Makefile.am

mkdir -p config
aclocal -I config
autoheader
libtoolize --automake
automake --add-missing --copy --foreign
autoconf
./configure --prefix "$INSTALLROOT" \
    CFLAGS="-I${ZLIB_ROOT}/include -Wno-implicit-function-declaration" \
    LDFLAGS="-L${ZLIB_ROOT}/lib"
make -C src ${JOBS:+-j$JOBS}
make -C src install
