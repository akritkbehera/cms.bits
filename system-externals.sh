package: system-externals
version: "1"
sources: 
 - file://system-externals.spec.in
variables:
 seeds: 'bash glibc glibc-headers openssl-libs libX11 libxcrypt readline ncurses-libs tcl tk mesa-libGLU libglvnd-glx libglvnd-opengl libXext libXft libXpm perl perl-libs libbrotli python3 perl-base perl-lib perl-filetest perl-overload perl-vars libcom_err krb5-libs libaio libgcc'
hooks: disable
---
mkdir -p $INSTALLROOT/etc/rpm

cp $SOURCEDIR/system-externals.spec.in $INSTALLROOT
touch $INSTALLROOT/system-externals.spec

cat << 'EoF' > "$INSTALLROOT/etc/profile.d/post-relocate.sh"
to_json() {
    sort -u | awk '
        BEGIN { printf "[" }
        { printf "%%s%%s", (NR>1 ? "," : ""), "\n  " ; gsub(/\\/,"\\\\"); gsub(/"/,"\\\""); printf "\"%%s\"", $0 }
        END { print (NR ? "\n" : "") "]" }
    '
}
EoF

cat << EoF >> "$INSTALLROOT/etc/profile.d/post-relocate.sh"
rpmspec -P \
  --define "pkgname $PKGNAME" \
  --define "pkgversion $PKGVERSION" \
  --define "pkghash $PKGHASH" \
  --define "tree $INSTALLROOT" \
  --define "seeds %(seeds)s" \
  --define "_rpmdir $INSTALLROOT/etc/rpm" \
  --define "arch $(uname -m)" \
  --define "_build_name_fmt %%{NAME}-%%{VERSION}.%%{ARCH}.rpm" \
  \$WORK_DIR/\$PP/system-externals.spec.in > \$WORK_DIR/\$PP/system-externals.spec
EoF

cat << EoF >> "$INSTALLROOT/etc/profile.d/post-relocate.sh"
rpmspec -q --provides "\$WORK_DIR/\$PP/system-externals.spec" | to_json > "\$WORK_DIR/$ARCHITECTURE/system-provides.json"
EoF
