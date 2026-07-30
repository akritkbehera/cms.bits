package: dwz
version: "0.15"
tag: dwz-%(version)s
source: https://forge.sourceware.org/dwz/dwz-mirror.git
requires:
 - xxhash
 - gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"

make ${JOBS:+-j $JOBS} \
	CFLAGS="-I${XXHASH_ROOT}/include -O2" \
	LDFLAGS="-L${XXHASH_ROOT}/lib"

mkdir -p $INSTALLROOT/bin
cp dwz $INSTALLROOT/bin
