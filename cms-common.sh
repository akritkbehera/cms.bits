package: cms-common
version: "1.0"
tag: a9321840d2b6bdefae0376d0aa8236e650290b19
source: https://github.com/cms-sw/cms-common
variables:
  revision: "1256"
env:
  REVISION: "%(revision)s"
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

find . -type f | xargs sed -i -e "s|@CMS_PREFIX@|$INSTALLROOT|g;s|@SCRAM_ARCH@|{$ARCHITECTURE}|"
rsync -a $BUILDDIR/ $INSTALLROOT/

cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
if [ -f \$WORK_DIR/cmsset_default.csh ] && [ -f \$WORK_DIR/etc/cms-common/revision ] ; then
  existing_rev=`cat \$WORK_DIR/etc/cms-common/revision`
  if [ \$existing_rev -ge "%(revision)s" ] ; then
    exit 0
  fi
fi

mkdir -p \$WORK_DIR/etc/cms-common  \$WORK_DIR/\$ARCHITECTURE/etc/profile.d

mkdir -p \$WORK_DIR/share \$WORK_DIR/etc/scramrc
  [ -d \$WORK_DIR/\$ARCHITECTURE/\$PKGNAME/\$PKGVERSION-\$PKGREVISION/share/etc/scramrc/SCRAM ] && rsync -a --delete \$WORK_DIR/\$ARCHITECTURE/\$PKGNAME/\$PKGVERSION-\$PKGREVISION/share/etc/scramrc/SCRAM/ \$WORK_DIR/etc/scramrc/SCRAM/
  [ -d \$WORK_DIR/\$ARCHITECTURE/\$PKGNAME/\$PKGVERSION-\$PKGREVISION/share/share ] && rsync -a \$WORK_DIR/\$ARCHITECTURE/\$PKGNAME/\$PKGVERSION-\$PKGREVISION/share/ \$WORK_DIR/share/

pushd \$WORK_DIR/\$ARCHITECTURE/\$PKGNAME/\$PKGVERSION-\$PKGREVISION
 for file in \$(find . -name '*' | grep -v ./etc/scramrc/SCRAM ); do
   if [ -d \$file ] ; then
     mkdir -p \$WORK_DIR/\$file
   else
     rm -f \$WORK_DIR/\$file
     cp -P \$file \$WORK_DIR/\$file
    fi
 done
popd
  echo "%(revision)s" > \$WORK_DIR/etc/cms-common/revision
