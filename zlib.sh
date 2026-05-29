package: zlib
version: "1.3.2"
tag: v%(version)s
source: https://github.com/madler/zlib
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
CONF_FLAG="-fPIC -O3 -DUSE_MMAP -DUNALIGNED_OK -D_LARGEFILE64_SOURCE=1"
CFLAGS="$CONF_FLAGS" ./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j$JOBS}
make install
