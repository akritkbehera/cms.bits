package:              SCRAMV1
version:              V3_00_84
variables:
 tag:                 7b4455f33cbf875bc8a618844a6e4fca84245104
 branch:              SCRAMV3
 github_user:         cms-sw
 OldDB:               /$ARCHITECTURE/lcg/SCRAMV1/scramdb/project.lookup
 SCRAM_ALL_VERSIONS:  shell(echo %(version)s | grep -E '^V[0-9]+_[0-9]+_[0-9]+$')
 SCRAM_REL_MINOR:     shell(echo %(version)s | grep -E '^V[0-9]+_[0-9]+_[0-9]+$' | sed 's|^\(V[0-9][0-9]*_[0-9][0-9]*\)_.*|\1|')
 SCRAM_REL_MAJOR:     shell(echo %(version)s | sed 's|^\(V[0-9][0-9]*\)_.*|\1|')
sources:
 - git+https://github.com/%(github_user)s/SCRAM.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

sed -i -e "s|@CMS_PATH@|$BITS_WORK_DIR/$PKG_NAME/$PKG_VERSION-$PKG_REVISION/|g;s|@SCRAM_VERSION@|%(version)s|g" SCRAM/__init__.py

mkdir $INSTALLROOT/bin $INSTALLROOT/docs
mv SCRAM $INSTALLROOT/
mv docs/man $INSTALLROOT/docs/
cp cli/scram $INSTALLROOT/bin/
cp cli/scram.py $INSTALLROOT/bin/
