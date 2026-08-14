export UCTOOL=$(echo "$PKG_NAME" | tr 'a-z-' 'A-Z_')

mkdir -p $INSTALLROOT/tools/selected $INSTALLROOT/tools/available

skipreqtools="%(skipreqtools)s"

for tool in $FULL_REQUIRES; do
    echo ">> Copying tool files from: $tool"
    uctool="${tool^^}"
    uctool="${uctool//-/_}"
    declare -n toolbase_ref="${uctool}_ROOT"
    declare -n toolver_ref="${uctool}_VERSION"
    "$BUILDDIR/bin/get_tools" "$toolbase_ref" "$toolver_ref" "$INSTALLROOT" "$tool"
done

$BUILDDIR/bin/get_tools "" "system" $INSTALLROOT "systemtools"
"$BUILDDIR/bin/get_tools" "$PYTHON_ROOT" "$PYTHON_VERSION" "$INSTALLROOT" "python3"

for stool in $(echo $skipreqtools | tr '[A-Z]' '[a-z]') ; do
  [ -f $INSTALLROOT/tools/selected/${stool}.xml ] || continue
  mv $INSTALLROOT/tools/selected/${stool}.xml $INSTALLROOT/tools/available
done

if [ -e $SCRAMV1_ROOT/bin/chktool ] ; then
  touch $INSTALLROOT/errors.log
  find $INSTALLROOT/tools -name '*.xml' -type f | (xargs $SCRAMV1_ROOT/bin/chktool >> $INSTALLROOT/errors.log 2>&1 || true)
  if [ $(grep 'ERROR:' $INSTALLROOT/errors.log | wc -l) -gt 0 ] ; then
    cat $INSTALLROOT/errors.log
    exit 1
  fi
  rm -f $INSTALLROOT/errors.log
fi

echo '<tool name="python-paths" version="1.0" revision="1">' > $INSTALLROOT/tools/selected/python-paths.xml
if [ -n "${PYTHON3PATH}" ]; then
    pth_file="$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/tool-deps.pth"
    xml_file="$INSTALLROOT/tools/selected/python-paths.xml"
    mkdir -p "$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}"
    : > "$pth_file"
    IFS=':' read -ra py_array <<< "$PYTHON3PATH"
    for pkg in "${py_array[@]}"; do
        echo "adding $pkg"
        echo "$pkg" >> "$pth_file"
    done
    echo "  <runtime name=\"PYTHON3PATH\" value=\"$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}\" type=\"path\"/>" >> "$xml_file"
fi
echo '</tool>' >> $INSTALLROOT/tools/selected/python-paths.xml

ALL_PY_BIN=""
ALL_PY_BIN_PKGS=""
for pkg in $(echo "$FULL_REQUIRES" | tr ' ' '\n' | grep -E '^py[0-9]?-'); do
  pk_name=$(echo "$pkg" | tr '[:upper:]' '[:lower:]')
  xml_path="$INSTALLROOT/tools/selected/${pk_name}.xml"
  [[ -f "$xml_path" ]] && continue
  uctool=$(echo "$pk_name" | tr '[:lower:]-' '[:upper:]_')
  ver_var="${uctool}_VERSION"
  rev_var="${uctool}_REVISION"
  root_var="${uctool}_ROOT"
  pk_ver=${!ver_var}
  pk_rev=${!rev_var}
  pk_root=${!root_var}
  echo "<tool name=\"$pk_name\" version=\"$pk_ver\" path=\"$pk_root\" revision=\"$pk_rev\">" > "$xml_path"
  if [[ -n "$pk_root" && -d "$pk_root/bin" ]]; then
    for b in "$pk_root/bin"/*; do
      b=$(basename "$b")
      ALL_PY_BIN+=" $b"
      ALL_PY_BIN_PKGS+=" ${b}:${pk_name}"
    done
    echo "  <runtime name=\"PATH\" value=\"\$TOOL_BASE/bin\" type=\"path\"/>" >> "$xml_path"
  fi
  echo "</tool>" >> "$xml_path"
done

if [[ -n "$ALL_PY_BIN" ]]; then
  DUP_BIN=$(echo "${ALL_PY_BIN}" | tr ' ' '\n' | grep -v '__pycache__' | sort | uniq -c | sed 's|^\s*||' | grep -v '^1 ' | sed 's|^.* ||')
else
  DUP_BIN=""
fi
if [ "${DUP_BIN}" != "" ] ; then
  for p in ${DUP_BIN} ; do
    echo ${ALL_PY_BIN_PKGS} | tr ' ' '\n' | grep "^${p}:"
  done
  echo "ERROR: Duplicate python binaries found. Please cleanup and make sure only one binary is available."
  exit 1
fi

if [ -e $INSTALLROOT/tools/selected/cuda-gcc-support.xml ] ; then
  if [ "$cuda_gcc_support" != "true" ] ; then
    rm -f $INSTALLROOT/tools/selected/cuda-gcc-support.xml
    echo "WARNING: CUDA does not support this GCC version, removing cuda-gcc-support.xml tool file"
  fi
fi

for type in selected available; do
    tmpl_file="$INSTALLROOT/tools/${type}.tmpl"
    type_dir="$INSTALLROOT/tools/${type}"
    : > "$tmpl_file"
    [[ -d "$type_dir" ]] || continue
    for xml in "$type_dir"/*.xml; do
        [[ -e "$xml" ]] || continue
        tool=$(basename "$xml")
        {
            echo "cat << 'EOF_TOOLFILE' >> \$PKGINSTROOT/tools/${type}/${tool}"
            cat "$xml"
            echo
            echo "EOF_TOOLFILE"
            echo
        } >> "$tmpl_file"
    done
    rm -rf "$type_dir"
done
python3 $WORK_DIR/wrapper-scripts/resolve_meta.py $INSTALLROOT/tools/selected.tmpl | cpp -P -x assembler-with-cpp > /tmp/selected.tmpl && mv /tmp/selected.tmpl $INSTALLROOT/tools/selected.tmpl
python3 $WORK_DIR/wrapper-scripts/resolve_meta.py $INSTALLROOT/tools/available.tmpl | cpp -P -x assembler-with-cpp > /tmp/available.tmpl && mv /tmp/available.tmpl $INSTALLROOT/tools/available.tmpl
