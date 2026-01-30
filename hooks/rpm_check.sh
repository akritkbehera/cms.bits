if [[ -z "$CACHED_TARBALL" ]]; then
  export BITS_CREATE_RPM=true
elif [[ -d "$INSTALLROOT/etc/rpm" ]]; then
  export BITS_CREATE_RPM=false
else
  echo "ERROR: RPM metadata missing in cached tarball for $PKGNAME" >&2
  exit 1
fi

create_rpm() {
    mkdir -p "$WORK_DIR/rpmbuild"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
    chmod -R u+w "$WORK_DIR/rpmbuild"
    cp "$WORK_DIR/spec" "$WORK_DIR/rpmbuild/SPECS/$PKGNAME.spec"
    RPM_REQUIRES=""
    for req in $RUNTIME_REQUIRES; do
        if [[ $req == defaults-* ]]; then
            continue
        fi
        req_upper=$(echo "$req" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        hash_var="${req_upper}_HASH"
        req_hash="${!hash_var}"
        # Convention: NAME_HASH-1-1.ARCH
        # Note: Using dot separator for architecture to match rpm_name definition below.
        dep_name="${req_upper}_${req_hash}-1-1.${ARCHITECTURE}"
        if [ -z "$RPM_REQUIRES" ]; then
            RPM_REQUIRES="Requires: ${dep_name}"
        else
            RPM_REQUIRES="${RPM_REQUIRES}, ${dep_name}"
        fi
    done

    if [ -z "$RPM_REQUIRES" ]; then
        RPM_REQUIRES="%{nil}"
    fi

    rpmbuild -bb \
        --define "rpm_name ${PKGNAME,,}_${PKGHASH}-1-1.${ARCHITECTURE}" \
        --define "rpm_requires ${RPM_REQUIRES}" \
        --define "version ${PKGVERSION}" \
        --define "revision ${PKGREVISION}" \
        --define "arch ${ARCHITECTURE}" \
        --define "pkgname ${PKGNAME}" \
        --define "work_dir ${WORK_DIR}" \
        --define "summary ${PKGNAME} ${PKGVERSION}-${PKGREVISION}" \
        --define "_topdir $WORK_DIR/rpmbuild" \
        --define "buildroot $WORK_DIR/rpmbuild/BUILDROOT/${PKGNAME}" \
	--define "inst_root $INSTALLROOT" \
        "$WORK_DIR/rpmbuild/SPECS/${PKGNAME}.spec" || exit 1

    RPM_FILE="$WORK_DIR/rpmbuild/RPMS/${PKGNAME}_${PKGHASH}-1-1.${ARCHITECTURE}.rpm"

}

mkdir -p "$INSTALLROOT/etc/rpm"
create_rpm

RPM_DB_DIR="$INSTALLROOT/etc/rpm"
touch $RPM_DB_DIR/requires.json
touch $RPM_DB_DIR/provides.json
rpm -qp --requires "$RPM_FILE" | jq -R -n '[inputs | sub("^\\s+";"") | sub("\\s+$";"") | select(length > 0)]' > "$RPM_DB_DIR/requires.json"
rpm -qp --provides "$RPM_FILE" | jq -R -n '[inputs | sub("^\\s+";"") | sub("\\s+$";"") | select(length > 0)]' > "$RPM_DB_DIR/provides.json"

cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EOF
RPM_DB_DIR="\$WORK_DIR/\$PP/etc/rpm"
PROVIDES_FILES=""

if [ -f "\$RPM_DB_DIR/provides.json" ]; then
  PROVIDES_FILES="\$RPM_DB_DIR/provides.json"
fi

for req in $RUNTIME_REQUIRES; do
  if [[ "\$req" == defaults-* ]]; then
    continue
  fi
  
  # Process the requirement name into a variable-friendly format
  req_upper=\$(echo "\$req" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  root_var="\${req_upper}_ROOT"
  pkg_root="\${!root_var}"
  
  if [ -n "\$pkg_root" ] && [ -f "\$pkg_root/etc/rpm/provides.json" ]; then
    PROVIDES_FILES="\$PROVIDES_FILES \$pkg_root/etc/rpm/provides.json"
  fi
done

\$WORK_DIR/check_dependencies.py "\$RPM_DB_DIR/requires.json" "\$WORK_DIR/system_provides.json" "\$PROVIDES_FILES"
EOF
