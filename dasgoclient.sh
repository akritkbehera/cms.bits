package: dasgoclient
version: "%(dasgoclient_tag)s.rev%(version_suffix)s"
variables:
  version_suffix: "00"
  dasgoclient_tag: v02.04.54
  x86_64_src: amd64
  aarch64_src: aarch64
  ppc64le_src: ppc64le
  riscv64_src: riscv64
  selected_src: "%%(%(platform_machine)s_src)s"
sources:
 - https://github.com/dmwm/dasgoclient/releases/download/%(dasgoclient_tag)s/dasgoclient_%(selected_src)s
requires:
 - gcc
---
mkdir -p "$INSTALLROOT/etc" "$INSTALLROOT/bin"

cat << 'EOF' > "$INSTALLROOT/etc/dasgoclient"
#!/bin/sh
#CMSDIST_FILE_REVISION=1
# Clean-up CMSSW environment
if [ -f $WORK_DIR/common/scram ] ; then
  eval `$WORK_DIR/common/scram unsetenv -sh`
fi
# Sourcing dasclient environment
SHARED_ARCH=`$WORK_DIR/common/cmsos`
[ $(ls $WORK_DIR/${SHARED_ARCH}_*/cms/dasgoclient 2>/dev/null | wc -l) -eq 0 ] && SHARED_ARCH=$(echo $SCRAM_ARCH | cut -d_ -f1,2)
LATEST_VERSION=`ls $WORK_DIR/${SHARED_ARCH}_*/cms/dasgoclient/v*/bin/dasgoclient | sed 's|.*/cms/dasgoclient/||' | sort | tail -1`
DASGOCLIENT=`ls $WORK_DIR/${SHARED_ARCH}_*/cms/dasgoclient/${LATEST_VERSION} | sort | tail -1`
$DASGOCLIENT "$@"
EOF

cp -pL "$SOURCEDIR/${SOURCE0}" "$INSTALLROOT/bin/dasgoclient"
chmod +x "$INSTALLROOT/bin/dasgoclient" "$INSTALLROOT/etc/dasgoclient"

mkdir -p "$INSTALLROOT/etc/profile.d"
cat << 'EoF' > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
mkdir -p "$WORK_DIR/common"
source_wrapper="$WORK_DIR/$PP/etc/dasgoclient"
shared_wrapper="$WORK_DIR/common/dasgoclient"
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
[ -e $WORK_DIR/share/overrides/bin/das_client ] || ln -sf ../../../common/dasgoclient $WORK_DIR/share/overrides/bin/das_client
EoF
