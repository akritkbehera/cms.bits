package: cms-common
version: "1.0"
tag: a9321840d2b6bdefae0376d0aa8236e650290b19
source: https://github.com/cms-sw/cms-common
variables:
  revision: "1256"
---
export PKGVERSION="%(revision)s"
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
export files="$(find . -type f -name '*' | grep -v '^./etc/scramrc/SCRAM' | sed 's|^\./||')"
echo $files
mkdir -p $INSTALLROOT/$PKGVERSION
rsync -a $BUILDDIR/ $INSTALLROOT/
pushd $INSTALLROOT
  find . -type f -exec sed -i -e "s|@CMS_PREFIX@|$WORK_DIR|g" -e "s|/lcg/|/|g" -e "s|/external/|/|g" {} +
popd
cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
#!/bin/bash -e
mkdir -p \$WORK_DIR/etc/$PKGNAME
mkdir -p \$WORK_DIR/$ARCHITECTURE/etc/profile.d

if [ -f \$WORK_DIR/cmsset_default.csh ] && [ -f \$WORK_DIR/etc/$PKGNAME/revision ] ; then
  oldrev=\$(cat \$WORK_DIR/etc/$PKGNAME/revision)
  if [ \$oldrev -gt \$PKGVERSION ] ; then
    exit 0
  fi
fi

mkdir -p \$WORK_DIR/share/profile.d
mkdir -p \$WORK_DIR/etc/scramrc
mkdir -p \$WORK_DIR/common

[ -d \$WORK_DIR/\$PP/etc/scramrc/SCRAM ] && rsync -a --delete \$WORK_DIR/\$PP/etc/scramrc/SCRAM/ \$WORK_DIR/etc/scramrc/SCRAM/
[ -d \$WORK_DIR/\$PP/share ] && rsync -a \$WORK_DIR/\$PP/share/ \$WORK_DIR/share/

pushd \$WORK_DIR/\$PP

files="$files"

while IFS= read -r file; do
  if [ -d "\$file" ] ; then
    mkdir -p "\$WORK_DIR/\$file"
  else
    rm -f "\$WORK_DIR/\$file"
    cp -P "\$file" "\$WORK_DIR/\$file"
  fi
done <<< "\$files"

popd
echo $PKGVERSION > \$WORK_DIR/etc/$PKGNAME/revision
EoF
