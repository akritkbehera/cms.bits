package: pythia6
version: "426"
sources:
 - http://cern.ch/service-spi/external/MCGenerators/distribution/%(package)s/%(package)s-%(version)s-src.tgz
patches:
 - pythia6-gcc14.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 
pushd $BUILDDIR/$PKGVERSION
  patch -p1 <$SOURCEDIR/$PATCH0
popd 
ls -l 

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"

TMPDIR="$BUILDDIR/config/"
rm -f "$TMPDIR"/config.{sub,guess}

