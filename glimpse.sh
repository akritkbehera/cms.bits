package: glimpse
version: 4.18.7-6
variables: 
  tag: 5426ca983218befa4aeadf21cad2305d90c84adb
sources:
 - git+https://github.com/cms-externals/glimpse.git?obj=master/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
build_requires:
 - autotools
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Legacy K&R-era C needs these with GCC > 13
CFLAGS=""
if [ "$(gcc -dumpversion | cut -d. -f1)" -gt 13 ]; then
    CFLAGS="-Wno-error=return-mismatch -Wno-error=implicit-int -Wno-error=implicit-function-declaration -Wno-error=old-style-definition -Wno-error=int-conversion -Wno-error=incompatible-pointer-types -Wno-error=missing-prototypes -Wno-error=redundant-decls -Wno-error=return-type -std=gnu90"
fi

CFLAGS="$CFLAGS" ./configure --prefix=$INSTALLROOT

perl -p -i -e "s|dynfilters||g" Makefile

make -j1
make install
