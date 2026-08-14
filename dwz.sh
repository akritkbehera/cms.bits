package: dwz
version: "0.16"
sources:
 - https://cmsrep.cern.ch/cmssw/download/dwz-%(version)s.tar.gz
requires:
 - xxhash
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j $JOBS} -C "$BUILDDIR" \
	CFLAGS="-I${XXHASH_ROOT}/include -O2" \
	LDFLAGS="-L${XXHASH_ROOT}/lib"

mkdir -p $INSTALLROOT/bin
cp "$BUILDDIR/dwz" $INSTALLROOT/bin
