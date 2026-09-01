package: rocgdb
version: "7.14"
sources:
  - https://github.com/ROCm/ROCgdb/archive/refs/tags/therock-%(version)s.tar.gz
build_requires:
  - Python
  - expat
  - zlib
  - xz
  - bison
  - flex
requires:
  - gcc
  - xz
  - zstd
  - zlib
  - Python
  - expat
  - rocdbgapi
  - rocm-comgr
  - rocr-runtime
---
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"

mkdir -p "$BUILDDIR/build"
cd "$BUILDDIR/build"
export PKG_CONFIG_PATH="$ROCDBGAPI_ROOT/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
../configure \
    --prefix="$INSTALLROOT" \
    --program-prefix=roc \
    --enable-64-bit-bfd \
    --enable-targets="x86_64-linux-gnu,amdgcn-amd-amdhsa" \
    --disable-ld --disable-gas --disable-gdbserver --disable-sim \
    --disable-binutils --disable-gprof \
    --enable-tui --disable-gdbtk --disable-gprofng --disable-shared \
    --with-expat --with-libexpat-prefix="$EXPAT_ROOT" \
    --with-lzma --with-liblzma-prefix="$XZ_ROOT" \
    --with-system-zlib --without-guile \
    --without-babeltrace \
    --with-python=python3 \
    --with-python-libdir="$PYTHON_ROOT/lib" \
    CPPFLAGS="-I$EXPAT_ROOT/include -I$XZ_ROOT/include -I$ZLIB_ROOT/include" \
    LDFLAGS="-L$EXPAT_ROOT/lib -L$XZ_ROOT/lib -L$ZLIB_ROOT/lib -L$PYTHON_ROOT/lib"

make ${JOBS:+-j$JOBS}
make install
