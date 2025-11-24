package: SCRAMV1
version: V3_00_84
tag: 7b4455f33cbf875bc8a618844a6e4fca84245104
source: https://github.com/cms-sw/SCRAM
---
export SCRAM_ALL_VERSION="V[0-9][0-9]*_[0-9][0-9]*_[0-9][0-9]*"
SCRAM_REL_MINOR=$(echo "$PKGVERSION" | grep "$SCRAM_ALL_VERSION" | sed 's|^\(V[0-9][0-9]*_[0-9][0-9]*\)_.*|\1|')
SCRAM_REL_MAJOR=$(echo "$PKGVERSION" | sed 's|^\(V[0-9][0-9]*\)_.*|\1|')

rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
sed -i -e "s|@CMS_PATH@|$WORK_DIR|g;s|@SCRAM_VERSION@|$PKGVERSION|g" SCRAM/__init__.py

mkdir $INSTALLROOT/bin $INSTALLROOT/docs
mv SCRAM $INSTALLROOT/
mv docs/man $INSTALLROOT/docs/
cp cli/scram $INSTALLROOT/bin/
cp cli/scram.py $INSTALLROOT/bin/

cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<'EoF'
#!/bin/bash -e
function SetLatestVersion() {
  vers=""
  for ver in $(find "$WORK_DIR/$ARCHITECTURE/$PKGNAME" -maxdepth 2 -mindepth 2 -name "bin" -type d \
      | sed 's|/bin$||' \
      | xargs -I '{}' basename '{}' \
      | grep -E "$1"| sed 's|-local[1-9]||g'); do

      ver_str=$(echo "$ver" \
        | sed 's|-.\+$||' \
        | tr '_' '\n' \
        | sed 's|V\([0-9]\)$|V0\1|; s|^\([0-9]\)$|0\1|' \
        | tr '\n' '_')
      
      vers="${ver_str}zzz:${ver} ${vers}"
  done

  echo "$vers" \
    | tr ' ' '\n' \
    | grep -v '^$' \
    | sort \
    | tail -1 \
    | sed 's|.*:||' \
    > "etc/$2"
}
EoF

cat >> "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
if [ "X${SCRAM_REL_MINOR}" == "X" ] ; then
  echo "You are trying to build SCRAM version %v which does not follow the SCRAM version policy. Valid SCRAM versions should be of the form V[0-9]+_[0-9]+_[0-9].*"
  exit 1
fi
if [ ! -d \$WORK_DIR/etc/scramrc ]; then
  mkdir -p \$WORK_DIR/etc/scramrc
  touch \$WORK_DIR/etc/scramrc/links.db
  echo 'CMSSW=\$SCRAM_ARCH/cms/cmssw/CMSSW_*' > \$WORK_DIR/etc/scramrc/cmssw.map
  echo 'CMSSW=\$SCRAM_ARCH/cms/cmssw-patch/CMSSW_*' > \$WORK_DIR/etc/scramrc/cmssw-patch.map
  echo 'CMSSW=\$SCRAM_ARCH/cms/coral/CORAL_*' > \$WORK_DIR/etc/scramrc/coral.map
fi

touch \$WORK_DIR/etc/scramrc/site.cfg
mkdir -p \$WORK_DIR/$ARCHITECTURE/etc/default-scram \$WORK_DIR/share/etc/default-scram
pushd \$WORK_DIR/$ARCHITECTURE
SetLatestVersion "$SCRAM_ALL_VERSION" "default-scramv1-version"
SetLatestVersion "$SCRAM_REL_MAJOR" "default-scram/${SCRAM_REL_MAJOR}"

if [ ! -d \$WORK_DIR/share/\$PKG_NAME ] ; then
  mkdir -p \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION
  rsync --links --ignore-existing --recursive --exclude='etc/'  \$WORK_DIR/$ARCHITECTURE/$PKG_NAME/$PKG_VERSION-$PKGREVISION/ \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION/
  # for f in \$(rsync --links --ignore-existing --recursive --itemize-changes \$WORK_DIR/$ARCHITECTURE/$PKG_NAME/$PKG_VERSION-$PKGREVISION/etc \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION | grep '^>f' | sed -e 's|.* ||') ; do
  #   sed -i -e 's|/$ARCHITECTURE/$PKG_NAME/$PKG_VERSION-$PKGREVISION|/share/$PKG_NAME/$PKG_VERSION|g' \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION/\$f
  # done
fi

mkdir -p \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION/etc/profile.d/
touch \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION/etc/profile.d/init.sh
echo "SCRAMV1_ROOT=\$WORK_DIR/share/$PKG_NAME/$PKG_VERSION" >> \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION/etc/profile.d/init.sh
echo "SCRAMV1_VERSION=$PKG_VERSION" >> \$WORK_DIR/share/$PKG_NAME/$PKG_VERSION/etc/profile.d/init.sh

pushd \$WORK_DIR/share
  SetLatestVersion "$SCRAM_ALL_VERSION" "default-scramv1-version"
  SetLatestVersion "$SCRAM_REL_MAJOR" "default-scram/${SCRAM_REL_MAJOR}"


  if [ \$(cat \$WORK_DIR/share/etc/default-scramv1-version) == $PKG_VERSION ]; then
      mkdir -p \$WORK_DIR/share/man/man1
      cp -f \$WORK_DIR/$ARCHITECTURE/$PKGNAME/$PKGVERSION-$PKGREVISION/docs/man/man1/scram.1 \$WORK_DIR/share/man/man1/scram.1
  fi
popd

pushd \$WORK_DIR/$ARCHITECTURE
  SetLatestVersion "$SCRAM_ALL_VERSION" "default-scramv1-version"
  SetLatestVersion "$SCRAM_REL_MAJOR" "default-scram/${SCRAM_REL_MAJOR}"
popd
EoF
