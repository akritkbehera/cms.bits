package: cms-common
version: vCMS
tag: a9321840d2b6bdefae0376d0aa8236e650290b19
source: https://github.com/cms-sw/cms-common
variables:
  revision: "1256"
---
export PKGVERSION="%(revision)s"
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
find . -type f -print0 | xargs -0 sed -i -e "s|@CMS_PREFIX@|${BITS_WORK_DIR}|g; s|@SCRAM_ARCH@|${ARCHITECTURE}|g"
mkdir -p $INSTALLROOT/$PKGVERSION
rsync $BUILDDIR/ $INSTALLROOT/

cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
#!/bin/bash -e
mkdir -p $WORK_DIR/etc/$PKGNAME
mkdir -p $WORK_DIR/$ARCHITECTURE/etc/profile.d
if [ -f $WORK_DIR/cmsset_default.csh ] && [ -f $WORK_DIR/etc/$PKGNAME/revision ] ; then
  oldrev=`cat $WORK_DIR/etc/$PKGNAME/revision`
  if [ $oldrev -ge $PKGVERSION ] ; then
    exit 0
  fi
fi
mkdir -p $WORK_DIR/share 
mkdir -p $WORK_DIR/etc/scramrc
mkdir -p $WORK_DIR/common
[ -d $BUILDDIR/etc/scramrc/SCRAM ] && rsync -a --delete $BUILDDIR/etc/scramrc/SCRAM/ $WORK_DIR/etc/scramrc/SCRAM/
[ -d $BUILDDIR/share ] && rsync -a $BUILDDIR/share/ $WORK_DIR/share/
pushd $BUILDDIR
  files=\$(find . -type f -name '*' | grep -v '^./etc/scramrc/SCRAM' | sed 's|^\./||')
  while IFS= read -r file; do
    if [ -d "\$file" ] ; then
      mkdir -p "$WORK_DIR/\$file"
    else
      rm -f "$WORK_DIR/\$file"
      cp -P "\$file" "$WORK_DIR/\$file"
     fi
  done <<< "\$files"
popd
echo $PKGVERSION > $WORK_DIR/etc/$PKGNAME/revision
EoF
