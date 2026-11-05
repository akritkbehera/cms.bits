package: pythia8
version: "317"
sources:
 - https://pythia.org/releases/pythia83/pythia8317.tgz
requires:
 - gcc
 - hepmc
 - hepmc3
 - lhapdf
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

./configure --prefix=$INSTALLROOT \
            --with-hepmc2=$HEPMC_ROOT \
            --with-hepmc3=$HEPMC3_ROOT \
            --with-lhapdf6=$LHAPDF_ROOT \
            --enable-shared \
            --with-mg5mes
make ${JOBS:+-j$JOBS}
make install
test -f $INSTALLROOT/lib/libpythia8lhapdf6.so || exit 1
# pythia8-config reads this configuration after the examples are removed.
install -m 644 "$BUILDDIR/Makefile.inc" "$INSTALLROOT/Makefile.inc"
rm -rf $INSTALLROOT/share/Pythia8/examples
test "$("$INSTALLROOT/bin/pythia8-config" --prefix)" = "$INSTALLROOT"

# Mirror CMSBUILD default archive cleanup for this recipe.
rm -f "$INSTALLROOT"/lib/*.a "$INSTALLROOT"/lib/*.la
