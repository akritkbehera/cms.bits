package: system-externals
version: "1"
variables:
 seeds: 'bash glibc glibc-headers openssl-libs libX11 libxcrypt readline ncurses-libs tcl tk mesa-libGLU libglvnd-glx libglvnd-opengl libXext libXft libXpm perl perl-libs libbrotli python3 perl-base perl-lib perl-filetest perl-overload perl-vars libcom_err krb5-libs libaio libgcc'
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
rpm -q --provides "\$WORK_DIR/\$PP/etc/rpm/$PKGNAME-${PKGVERSION}_$PKGHASH.$(uname -i).rpm" | to_json > "\$WORK_DIR/$ARCHITECTURE/system-provides.json"
EoF
