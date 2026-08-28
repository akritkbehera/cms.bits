package: system-externals
version: "1"
variables:
 seeds: 'bash glibc glibc-headers openssl-libs libX11 libxcrypt readline ncurses-libs tcl tk mesa-libGLU libglvnd-glx libglvnd-opengl libXext libXft libXpm perl perl-libs libbrotli python3 perl-base perl-lib perl-filetest perl-overload perl-vars libcom_err krb5-libs libaio libgcc'
hook: disable
---
mkdir -p $INSTALLROOT/etc/rpm

rpmbuild -bb \
  --define "pkgname $PKGNAME" \
  --define "pkgversion $PKGVERSION" \
  --define "pkghash $PKGHASH" \
  --define "tree $INSTALLROOT" \
  --define "seeds %(seeds)s" \
  --define "_rpmdir $INSTALLROOT/etc/rpm" \
  --define "arch $(uname -m)" \
  --define "_build_name_fmt %%{NAME}-%%{VERSION}.%%{ARCH}.rpm" \
  $BITS_CONFIG_DIR/system-externals.spec.in

cat << EoF > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
DBPATH="\$WORK_DIR/var/lib/rpm"
RPMFILE="\$WORK_DIR/$ARCHITECTURE/external/$PKGNAME/$PKGVERSION-$PKGREVISION/etc/rpm/system-externals-${PKGVERSION}_$PKGHASH.$(uname -m).rpm"

if [ ! -e "\$DBPATH/rpmdb.sqlite" ]; then
  mkdir -p "\$DBPATH"
  rpm --dbpath "\$DBPATH" --initdb
fi

if rpm --dbpath "\$DBPATH" -q system-externals-1_$PKGHASH >/dev/null 2>&1; then
  echo "already registered: system-externals-1_$PKGHASH"
else
  rpm -i --dbpath "\$DBPATH" --nodeps "\$RPMFILE"
fi
if [ -f "\$WORK_DIR/system-externals.hash" ]; then
    rm -f "\$WORK_DIR/system-externals.hash"
fi

echo "$PKGHASH" > "\$WORK_DIR/system-externals.hash"
chmod 444 "\$WORK_DIR/system-externals.hash"
EoF
