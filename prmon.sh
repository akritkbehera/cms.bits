package: prmon
version: v2026022600.3.2.0
variables:
  prmon_tag:  "3.2.0"
  build_type: static-gnu115-opt
  arch:       "%(platform_machine)s"
sources:
  - https://github.com/HSF/prmon/releases/download/v%(prmon_tag)s/prmon_%(prmon_tag)s_%(arch)s-%(build_type)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

rsync -a "$BUILDDIR/" "$INSTALLROOT/"

mkdir -p "$INSTALLROOT/etc"

CMS_PATH=$(cd "$INSTALLROOT/../../../../../.." && pwd)
sed -e "s|@CMS_PATH@|${CMS_PATH}|" << 'EOF' > "$INSTALLROOT/etc/prmon-env.sh"
#CMSDIST_FILE_REVISION=1
latest_prmon=$(ls -d @CMS_PATH@/share/$(uname -m)/cms/prmon/v*/bin 2>/dev/null | sort | tail -1)
export PATH="${latest_prmon}${PATH:+:$PATH}"
EOF

sed -e "s|@CMS_PATH@|${CMS_PATH}|" << 'EOF' > "$INSTALLROOT/etc/prmon-env.csh"
#CMSDIST_FILE_REVISION=2
set prmon_arch=`uname -m`
set latest_prmon=`ls -d @CMS_PATH@/share/${prmon_arch}/cms/prmon/v*/bin 2>/dev/null | sort | tail -1`
if ( $?PATH ) then
    setenv PATH "${latest_prmon}:$PATH"
else
    setenv PATH "${latest_prmon}"
endif
unset latest_prmon
unset prmon_arch
EOF
