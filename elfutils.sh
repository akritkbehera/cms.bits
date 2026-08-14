package: elfutils
version: "0.195"
sources:
 - https://sourceware.org/elfutils/ftp/%(version)s/elfutils-%(version)s.tar.bz2
build_requires:
 - gmake
 - bison
 - flex
requires:
 - zlib
 - bz2lib
 - xz
 - gcc
---
tar -xjf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"
export CPPFLAGS="-I${ZLIB_ROOT}/include -I${BZ2LIB_ROOT}/include -I${XZ_ROOT}/include"
export LDFLAGS="-L${ZLIB_ROOT}/lib -L${BZ2LIB_ROOT}/lib -L${XZ_ROOT}/lib"
./configure --prefix="$INSTALLROOT" --disable-static --enable-install-elfh \
            --disable-libdebuginfod --disable-debuginfod \
            --enable-thread-safety --disable-nls

make ${JOBS:+-j$JOBS} V=1
make install V=1

# We do not ship a xz/lib/pkgconfig/liblzma.pc file, so drop the liblzma
# Requires from libdw.pc and link against xz explicitly instead.
if grep -q ' liblzma' "$INSTALLROOT/lib/pkgconfig/libdw.pc"; then
  sed -i -e 's| liblzma||' "$INSTALLROOT/lib/pkgconfig/libdw.pc"
  sed -i -e "s|^Cflags: |Cflags: -I${XZ_ROOT}/include |" "$INSTALLROOT/lib/pkgconfig/libdw.pc"
  sed -i -e "s|^Libs.private: |Libs.private: -L${XZ_ROOT}/lib -llzma |" "$INSTALLROOT/lib/pkgconfig/libdw.pc"
fi
