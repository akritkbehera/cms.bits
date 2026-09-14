package: numactl
version: "2.0.19"
variables:
  tag: v%(version)s
sources:
  - https://github.com/numactl/numactl/archive/%(tag)s.tar.gz
build_requires:
 - autotools
requires:
 - gcc
prepend_path:
  MANPATH: $NUMACTL_ROOT/share/man
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./autogen.sh
./configure \
  --prefix=$INSTALLROOT \
  --enable-shared \
  --disable-static \
  --disable-dependency-tracking \
  --with-pic \
  --with-gnu-ld
  
make ${JOBS:+-j $JOBS}
make install

rm -rf $INSTALLROOT/lib/pkgconfig
