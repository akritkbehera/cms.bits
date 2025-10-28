package: coral-tools
version: "v1"
tag: 083d26ec3af5ef62fd40273d0be61d2553bbd635
source: https://github.com/akritkbehera/scram-tools.file.git
variables:
  skipreqtools: jcompiler
  override_microarch: "-march=x86-64-v2"
  package_vectorization: ""
requires:
  - gcc
  - Python
  - zlib
  - bz2lib
  - expat
  - xz
  - db6
  - libuuid
  - gdbm
  - libffi
  - sqlite
  - Python
  - curl
  - numactl
  - fmt
  - zstd
  - cuda
  - rocm
  - xpmem
  - gdrcopy
  - rdma-core
  - libpciaccess
  - libxml2
  - hwloc
  - libfabric
  - ucx
  - pacparser
  - openmpi
  - xerces-c
  - cppunit
  - pcre
  - frontier_client
  - boost
  - oracle
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

export UCTOOL=$(echo "$PKG_NAME" | tr 'a-z-' 'A-Z_')

mkdir -p $INSTALLROOT/tools/selected $INSTALLROOT/tools/available

skipreqtools="%(skipreqtools)s"

for tool in $REQUIRES; do
    echo ">> Copying tool files from: $tool"

    # Convert to uppercase and replace hyphens with underscores
    uctool="${tool^^}"
    uctool="${uctool//-/_}"

    # Use nameref for indirect variable reference
    declare -n toolbase_ref="${uctool}_ROOT"
    declare -n toolver_ref="${uctool}_VERSION"

    "$BUILDDIR/bin/get_tools" "$toolbase_ref" "$toolver_ref" "$INSTALLROOT" "$tool"
done

$BUILDDIR/bin/get_tools "" "system" $INSTALLROOT "systemtools"

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
    : > "$pth_file"  # Create/truncate file

    # Split on colons and write directly
    IFS=':' read -ra py3_array <<< "$PYTHON3PATH"
    for pkg in "${py3_array[@]}"; do
        echo "adding $pkg"
        echo "$pkg" >> "$pth_file"
    done

    echo "  <runtime name=\"PYTHON3PATH\" value=\"$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}\" type=\"path\"/>" >> "$xml_file"
fi

echo '</tool>' >> $INSTALLROOT/tools/selected/python-paths.xml

ALL_PY_BIN=""
ALL_PY_BIN_PKGS=""

for pkg in $(echo "$FULL_REQUIRES" | tr ' ' '\n' | grep '/py-'); do
  pk_name=$(echo "$pkg" | cut -d/ -f2 | tr '[:upper:]' '[:lower:]')
  xml_path="$INSTALLROOT/tools/selected/${pk_name}.xml"

  [[ -f "$xml_path" ]] && continue

  uctool=$(echo "$pk_name" | tr '[:lower:]-' '[:upper:]_')
  ver_var="${uctool}_VERSION"
  rev_var="${uctool}_REVISION"
  pk_ver=${!ver_var}
  pk_rev=${!rev_var}

  echo "<tool name=\"$pk_name\" version=\"$pk_ver\" revision=\"$pk_rev\">" > "$xml_path"

  bindir="$BITS_WORK_DIR/$ARCHITECTURE/$pkg/$pk_ver-$pk_rev/bin"
  if [[ -d "$bindir" ]]; then
    for b in "$bindir"/*; do
      b=$(basename "$b")
      ALL_PY_BIN+=" $b"
      ALL_PY_BIN_PKGS+=" ${b}:${pk_name}"
    done

    {
      echo "  <client>"
      echo "    <environment name=\"${uctool}_BASE\" default=\"$INSTALLROOT/${pk_name}\"/>"
      echo "  </client>"
      echo "  <runtime name=\"PATH\" value=\"\$${uctool}_BASE/bin\" type=\"path\"/>"
    } >> "$xml_path"
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
    # Reset the template file
    : > "$tmpl_file"
    # Skip if the directory doesn't exist
    [[ -d "$type_dir" ]] || continue
    # Process each XML file and embed it in the template
    for xml in "$type_dir"/*.xml; do
        [[ -e "$xml" ]] || continue
        tool=$(basename "$xml")
        {
            echo "cat << 'EOF_TOOLFILE' >> \$PKGINSTROOT/tools/${type}/${tool}"
            cat "$xml"
            echo "EOF_TOOLFILE"
            echo
        } >> "$tmpl_file"
    done
    # Remove original XML directory after embedding
    rm -rf "$type_dir"
done
