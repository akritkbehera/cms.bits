package: das_client
version: "v03.01.00"
variables:
  tag: "%(version)s"
  pkg: DAS
sources:
  - git+https://github.com/dmwm/DAS.git?obj=master/%(tag)s&export=%(pkg)s&output=/%(pkg)s-%(version)s.tgz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"

mkdir -p "$INSTALLROOT/bin"
cp "$BUILDDIR/%(pkg)s/src/python/DAS/tools/das_client.py" "$INSTALLROOT/bin/"

mkdir -p "$INSTALLROOT/etc"
cat << 'EOF' > "$INSTALLROOT/etc/das_client"
#!/bin/sh
#CMSDIST_FILE_REVISION=1
eval `scram unsetenv -sh 2>/dev/null`
SHARED_ARCH=`cmsos`
LATEST_VERSION=`cd $WORK_DIR && ls ${SHARED_ARCH}_*/cms/das_client/v*/etc/profile.d/init.sh | sed 's|.*/cms/das_client/||' | sort | tail -1`
DAS_ENV=`ls $WORK_DIR/${SHARED_ARCH}_*/cms/das_client/${LATEST_VERSION} | sort | tail -1`
source $DAS_ENV
if [ $# == 0 ] || [ "$1" == "--help" ] || [ "$1" == "-help" ]
then
    $DAS_CLIENT_ROOT/bin/das_client.py --help | sed 's/das_client.py/das_client/'
else
    $DAS_CLIENT_ROOT/bin/das_client.py "$@"
fi
EOF
chmod +x "$INSTALLROOT/etc/das_client"

mkdir -p "$INSTALLROOT/etc/profile.d"
cat << 'EoF' > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
mkdir -p "$WORK_DIR/common"
source_wrapper="$WORK_DIR/$PP/etc/das_client"
shared_wrapper="$WORK_DIR/common/das_client"
new_revision=$(sed -n 's/^#CMSDIST_FILE_REVISION=//p' "$source_wrapper")
old_revision=0
if [ -f "$shared_wrapper" ]; then
    old_revision=$(sed -n 's/^#CMSDIST_FILE_REVISION=//p' "$shared_wrapper")
fi
if [ "${old_revision:-0}" -lt "$new_revision" ]; then
    temporary=$(mktemp "$shared_wrapper.XXXXXX")
    cp -p "$source_wrapper" "$temporary"
    mv -f "$temporary" "$shared_wrapper"
fi
mkdir -p $WORK_DIR/share/overrides/bin
[ -e $WORK_DIR/share/overrides/bin/das_client.py ] || ln -sf ../../../common/das_client $WORK_DIR/share/overrides/bin/das_client.py
EoF
