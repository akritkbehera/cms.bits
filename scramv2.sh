package:      SCRAMV2
version:      V2_2_9_pre23
variables:
 tag:         a58bd81a6c7bd8e763e34274470bfc97054fb808
 branch:      SCRAMV2
 github_user: cms-sw
 SCRAM_ALL_VERSIONS:  shell(echo %(version)s | grep -E '^V[0-9]+_[0-9]+_[0-9]+$')
 SCRAM_REL_MINOR:     shell(echo %(version)s | grep -E '^V[0-9]+_[0-9]+_[0-9]+$' | sed 's|^\(V[0-9][0-9]*_[0-9][0-9]*\)_.*|\1|')
 SCRAM_REL_MAJOR:     shell(echo %(version)s | sed 's|^\(V[0-9][0-9]*\)_.*|\1|')
sources:
 - git+https://github.com/%(github_user)s/SCRAM.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
build_requires:
 - gmake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

gmake ${JOBS:+-j$JOBS} all INSTALL_BASE="$BITS_WORK_DIR/$ARCHITECTURE/$PKG_NAME/$PKG_VERSION-$PKG_REVISION/" VERSION=%(version)s PREFIX=$INSTALLROOT
gmake ${JOBS:+-j$JOBS} install INSTALL_BASE="$BITS_WORK_DIR/$ARCHITECTURE/$PKG_NAME/$PKG_VERSION-$PKG_REVISION/" VERSION=%(version)s PREFIX=$INSTALLROOT
