package: zlib
version: "1.3.2"
tag: v%(version)s
source: https://github.com/madler/zlib
build_requires:
 - gmake
requires:
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
CONF_FLAGS="-fPIC -O3 -DUSE_MMAP -DUNALIGNED_OK -D_LARGEFILE64_SOURCE=1 -D_DEFAULT_SOURCE"
CFLAGS="$CONF_FLAGS" ./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j$JOBS}
make install
