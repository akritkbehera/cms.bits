tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
chmod +x "$BUILDDIR/bin/get_tools"
chmod +x "$BUILDDIR/bin/fix_tool_variables"
[ -f "$BUILDDIR/bin/get_vectorized_tools" ] && chmod +x "$BUILDDIR/bin/get_vectorized_tools"
#!include  <microarch-flags.file>
#!include  <tool-conf-src.file>
mkdir -p touch $INSTALLROOT/etc/profile.d
touch $INSTALLROOT/etc/profile.d/post-relocate.sh
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
  cp $INSTALLROOT/tools/selected.tmpl \$WORK_DIR/$PKGNAME.selected.tmpl
  cp $INSTALLROOT/tools/available.tmpl \$WORK_DIR/$PKGNAME.available.tmpl
EoF
