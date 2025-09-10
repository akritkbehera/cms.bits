package: dwz
version: "0.15"
tag: 0171f3e7ac09fa44cb1eb299f2703faa113a207e
variables:
 dwz_branch: "dwz_branch"
 dwz_commit: "0171f3e7ac09fa44cb1eb299f2703faa113a207e"
source: https://sourceware.org/git/dwz.git
requires:
 - xxhash
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded \
    "$SOURCEDIR"/ "$BUILDDIR"/

make ${JOBS+-j $JOBS} \
	CFLAGS="-I${XXHASH_ROOT}/include -O2" \
	LDFLAGS="-L${XXHASH_ROOT}/lib"

mkdir -p $INSTALLROOT/bin
cp dwz $INSTALLROOT/bin
