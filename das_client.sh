package: das_client
version: 03.01.00
tag: v%(version)s
source: https://github.com/dmwm/DAS.git
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

mkdir -p $INSTALLROOT/bin
cp DAS/src/python/DAS/tools/das_client.py $INSTALLROOT/bin

mkdir -p $INSTALLROOT/etc
cat << EOF > $INSTALLROOT/etc/das_client
#!/bin/sh
# VERSION:$ARCHITECTURE/$PKG_VERSION

# Clean-up CMSSW environment
eval `scram unsetenv -sh 2>/dev/null`

# Sourcing dasclient environment
export SHARED_ARCH=`cmsos`
LATEST_VERSION=`cd %{instroot}; ls ${SHARED_ARCH}_*/%{pkgcategory}/%{pkgname}/v*/etc/profile.d/init.sh | sed 's|.*/%{pkgcategory}/%{pkgname}/||' | sort | tail -1`
DAS_ENV=`ls %{instroot}/${SHARED_ARCH}_*/%{pkgcategory}/%{pkgname}/${LATEST_VERSION} | sort | tail -1`
source $DAS_ENV
if [ $# == 0 ] || [ "$1" == "--help" ] || [ "$1" == "-help" ]
then
    $DAS_CLIENT_ROOT/bin/das_client.py --help | sed 's/das_client.py/das_client/'
else
    $DAS_CLIENT_ROOT/bin/das_client.py "$@"
fi
EOF
