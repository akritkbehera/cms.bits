package: cmssw-tools
version: "v1"
tag: 95c34a89349f361c7172a9884f48068fa089ebf1
source: https://github.com/akritkbehera/scram-tools.file.git
variables:
  skipreqtools: jcompiler
requires:
 - AXOL1TL
 - TOPO
 - CICADA
 - OpenBLAS
 - celeritas
 - crab
 - cmssw-wm-tools
 - google-benchmark
 - catch2
 - starlight
 - alpgen
 - boost
 - bz2lib
 - cepgen
 - clang-uml
 - classlib
 - clhep
 - conifer
# - coral
 - cppunit
 - cpu_features
 - curl
 - das_client
 - db6
 - davix
 - evtgen
 - expat
# - fakesystem
 - flatbuffers
 - fmt
 - gbl
 - gcc
 - gdbm
 - geant4
 - geant4-data
 - g4hepem
 - glimpse
 - gmake
 - GSL
 - highfive
 - hector
 - hepmc
 - hepmc3
 - heppdt
 - herwig7
 - hydjet
 - hydjet2
 - ittnotify
 - jemalloc
 - jemalloc-debug
 - jemalloc-prof
 - json
 - ktjet
 - EMTF_NN
 - L1METML
 - L1TSC4NGJetModel
 - lhapdf
 - libjpeg-turbo
 - libpng
 - libtiff
 - libungif
 - libxml2
 - lwtnn
 - meschach
 - pcre
 - pcre2
 - photospp
 - pyquen
 - pythia6
 - pythia8
 - Python
 - ROOT
 - libpciaccess
 - numactl
 - hwloc
 - rdma-core
 - ucx
 - libfabric
 - openmpi
 - mpich
 - mpi
 - sigcpp
 - sqlite
 - tauolapp
 - thepeg
 - libuuid
 - xerces-c
 - dcap
 - frontier_client
 - isal
 - XRootD
 - xrdcl-record
 - dd4hep
 - valgrind
#  - cmsswdata
 - zstd
 - hls
 - opencv
 - abseil-cpp
 - c-ares
 - re2
 - grpc
 - onnxruntime
 - tensorflow
 - tensorflow-xla-runtime
 - py-tensorflow
 - TOoLLiP
 - triton-inference-client
 - hdf5
 - yaml-cpp
 - yoda
 - FFTW3
 - fftjet
 - professor2
 - xz
 - lz4
 - protobuf
 - lcov
 - llvm
 - TBB
 - mctester
 - vdt
 - gnuplot
 - sloccount
 - mille
 - millepede
 - pacparser
 - git
 - git-lfs
 - fastjet
 - fastjet-contrib
 - opencl
 - opencl-cpp
 - qd
 - blackhat
 - sherpa
 - fasthadd
 - eigen
 - gdb
 - libxslt
 - giflib
 - FreeType
 - utm
 - libffi
 - CSCTrackFinderEmulation
 - tinyxml2
 - md5
 - gosamcontrib
 - gosam
 - madgraph5amcatnlo
 - python_tools
 - dasgoclient
 - dablooms
 - rivet
 - zlib
 - openldap
 - gperftools
 - cuda
 - cuda-compatible-runtime
 - gdrcopy
 - cudnn
 - alpaka
 - clue
 - cluestering
 - libunwind
 - igprof
 - heaptrack
 - openloops
 - mozsearch
 - tkonlinesw
 - oracle
 - icc
 - icx
 - intel-vtune
 - ruff
 - rocm
 - cmsmon-tools
 - log4cplus
 - dip
 - tkonlinesw-fake
 - oracle-fake
 - xtensor
 - xtl
 - xgboost
# - pytorch
# - pytorch-custom-ops
---
# =============================================================================
# coral-tools: Generates SCRAM tool configuration files for CMS software
# =============================================================================
# This script creates XML tool files that tell SCRAM (the CMS build system)
# where to find libraries, headers, and binaries for each dependency.
#   $INSTALLROOT/tools/selected/  - XML files for active tools
#   $INSTALLROOT/tools/available/ - XML files for optional/inactive tools
#   $INSTALLROOT/tools/*.tmpl     - Templates with embedded XML (for coral-tool-conf)
# =============================================================================
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
chmod +x $BUILDDIR/bin/get_tools
chmod +x $BUILDDIR/bin/fix_tool_variables
# Convert package name to uppercase with underscores (e.g., coral-tools -> CORAL_TOOLS)
# This naming convention is used for environment variables
export UCTOOL=$(echo "$PKG_NAME" | tr 'a-z-' 'A-Z_')

# Create directory structure for tool XML files
mkdir -p $INSTALLROOT/tools/selected $INSTALLROOT/tools/available

# Tools listed here will be moved to 'available' (present but not active)
skipreqtools="%(skipreqtools)s"

# -----------------------------------------------------------------------------
# STEP 2: Generate XML tool files for each dependency
# -----------------------------------------------------------------------------
# Loop through all required packages and generate their tool configuration
# The get_tools binary reads tool templates and creates XML files with paths
for tool in $REQUIRES; do
    echo ">> Copying tool files from: $tool"

    # Convert tool name to uppercase with underscores for env var lookup
    # e.g., "frontier_client" -> "FRONTIER_CLIENT"
    uctool="${tool^^}"
    uctool="${uctool//-/_}"

    # Use bash nameref to dynamically reference environment variables
    # ${TOOLNAME}_ROOT contains the install path (e.g., /opt/cms/gcc)
    # ${TOOLNAME}_VERSION contains the version string (e.g., 12.3.0)
    declare -n toolbase_ref="${uctool}_ROOT"
    declare -n toolver_ref="${uctool}_VERSION"

    # Call get_tools to generate the XML tool file
    # Args: <tool_root> <tool_version> <output_dir> <tool_name>
    "$BUILDDIR/bin/get_tools" "$toolbase_ref" "$toolver_ref" "$INSTALLROOT" "$tool"
done


# Generate system tools (compiler wrappers, system libraries, etc.)
# These don't have a specific ROOT path, just use "system" as version
$BUILDDIR/bin/get_tools "" "system" $INSTALLROOT "systemtools"

# Generate python3 tool using the same Python installation (different SCRAM tool name)
"$BUILDDIR/bin/get_tools" "$PYTHON_ROOT" "$PYTHON_VERSION" "$INSTALLROOT" "python3"

# -----------------------------------------------------------------------------
# STEP 3: Move skipped tools from selected -> available
# -----------------------------------------------------------------------------
# Some tools are built but not actively used (e.g., jcompiler)
# Move them to 'available' so they exist but aren't in the default toolchain
for stool in $(echo $skipreqtools | tr '[A-Z]' '[a-z]') ; do
  [ -f $INSTALLROOT/tools/selected/${stool}.xml ] || continue
  mv $INSTALLROOT/tools/selected/${stool}.xml $INSTALLROOT/tools/available
done

# -----------------------------------------------------------------------------
# STEP 4: Validate all tool XML files (if SCRAM validator exists)
# -----------------------------------------------------------------------------
# chktool validates XML syntax and checks that referenced paths exist
if [ -e $SCRAMV1_ROOT/bin/chktool ] ; then
  touch $INSTALLROOT/errors.log
  # Run chktool on all XML files, collect errors
  find $INSTALLROOT/tools -name '*.xml' -type f | (xargs $SCRAMV1_ROOT/bin/chktool >> $INSTALLROOT/errors.log 2>&1 || true)
  # Fail the build if any errors were found
  if [ $(grep 'ERROR:' $INSTALLROOT/errors.log | wc -l) -gt 0 ] ; then
    cat $INSTALLROOT/errors.log
    exit 1
  fi
  rm -f $INSTALLROOT/errors.log
fi

# -----------------------------------------------------------------------------
# STEP 5: Setup Python paths for SCRAM
# -----------------------------------------------------------------------------
# Create a tool file that configures PYTHON3PATH for the build environment
# This allows Python to find packages installed by dependencies

echo '<tool name="python-paths" version="1.0" revision="1">' > $INSTALLROOT/tools/selected/python-paths.xml

if [ -n "${PYTHON3PATH}" ]; then
    # Create a .pth file that Python reads to extend sys.path
    pth_file="$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}/tool-deps.pth"
    xml_file="$INSTALLROOT/tools/selected/python-paths.xml"

    mkdir -p "$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}"
    : > "$pth_file"  # Create/truncate the .pth file

    # PYTHON3PATH is colon-separated; split and write each path to .pth file
    # Python automatically reads .pth files and adds their contents to sys.path
    IFS=':' read -ra py3_array <<< "$PYTHON3PATH"
    for pkg in "${py3_array[@]}"; do
        echo "adding $pkg"
        echo "$pkg" >> "$pth_file"
    done

    # Add runtime environment variable to the tool XML
    echo "  <runtime name=\"PYTHON3PATH\" value=\"$INSTALLROOT/${PYTHON3_LIB_SITE_PACKAGES}\" type=\"path\"/>" >> "$xml_file"
fi

echo '</tool>' >> $INSTALLROOT/tools/selected/python-paths.xml

# -----------------------------------------------------------------------------
# STEP 6: Generate tool files for Python packages (py-*)
# -----------------------------------------------------------------------------
# Python packages from FULL_REQUIRES need their own tool files
# This creates XML files that add their bin/ directories to PATH

# Track all Python binaries to detect conflicts
ALL_PY_BIN=""
ALL_PY_BIN_PKGS=""

# Find all Python packages (paths containing '/py-')
for pkg in $(echo "$FULL_REQUIRES" | tr ' ' '\n' | grep '/py-'); do
  # Extract package name (e.g., "external/py-numpy" -> "py-numpy")
  pk_name=$(echo "$pkg" | cut -d/ -f2 | tr '[:upper:]' '[:lower:]')
  xml_path="$INSTALLROOT/tools/selected/${pk_name}.xml"

  # Skip if tool file already exists (avoid duplicates)
  [[ -f "$xml_path" ]] && continue

  # Convert to uppercase for environment variable lookup
  # e.g., "py-numpy" -> "PY_NUMPY"
  uctool=$(echo "$pk_name" | tr '[:lower:]-' '[:upper:]_')
  ver_var="${uctool}_VERSION"
  rev_var="${uctool}_REVISION"
  pk_ver=${!ver_var}  # Indirect variable expansion
  pk_rev=${!rev_var}

  # Start the XML tool file
  echo "<tool name=\"$pk_name\" version=\"$pk_ver\" revision=\"$pk_rev\">" > "$xml_path"

  # Check if this Python package has executables
  bindir="$BITS_WORK_DIR/$ARCHITECTURE/$pkg/$pk_ver-$pk_rev/bin"
  if [[ -d "$bindir" ]]; then
    # Record all binaries for duplicate detection later
    for b in "$bindir"/*; do
      b=$(basename "$b")
      ALL_PY_BIN+=" $b"
      ALL_PY_BIN_PKGS+=" ${b}:${pk_name}"
    done

    # Add client environment and PATH to the tool file
    # This tells SCRAM where to find the package and adds its bin/ to PATH
    {
      echo "  <client>"
      echo "    <environment name=\"${uctool}_BASE\" default=\"$INSTALLROOT/${pk_name}\"/>"
      echo "  </client>"
      echo "  <runtime name=\"PATH\" value=\"\$${uctool}_BASE/bin\" type=\"path\"/>"
    } >> "$xml_path"
  fi

  echo "</tool>" >> "$xml_path"
done

# -----------------------------------------------------------------------------
# STEP 7: Check for duplicate Python binaries
# -----------------------------------------------------------------------------
# Multiple Python packages might install the same binary name (e.g., 'pytest')
# This is an error - we need unique binary names to avoid conflicts

if [[ -n "$ALL_PY_BIN" ]]; then
  # Count occurrences of each binary, filter to those appearing more than once
  # Excludes __pycache__ directories
  DUP_BIN=$(echo "${ALL_PY_BIN}" | tr ' ' '\n' | grep -v '__pycache__' | sort | uniq -c | sed 's|^\s*||' | grep -v '^1 ' | sed 's|^.* ||')
else
  DUP_BIN=""
fi

# If duplicates found, report them and fail the build
if [ "${DUP_BIN}" != "" ] ; then
  for p in ${DUP_BIN} ; do
    # Show which packages provide each duplicate binary
    echo ${ALL_PY_BIN_PKGS} | tr ' ' '\n' | grep "^${p}:"
  done
  echo "ERROR: Duplicate python binaries found. Please cleanup and make sure only one binary is available."
  exit 1
fi

# -----------------------------------------------------------------------------
# STEP 8: Handle CUDA-GCC compatibility
# -----------------------------------------------------------------------------
# CUDA has specific GCC version requirements. If the current GCC isn't
# supported by CUDA, remove the cuda-gcc-support tool file
if [ -e $INSTALLROOT/tools/selected/cuda-gcc-support.xml ] ; then
  if [ "$cuda_gcc_support" != "true" ] ; then
    rm -f $INSTALLROOT/tools/selected/cuda-gcc-support.xml
    echo "WARNING: CUDA does not support this GCC version, removing cuda-gcc-support.xml tool file"
  fi
fi

# -----------------------------------------------------------------------------
# STEP 9: Create template files for coral-tool-conf
# -----------------------------------------------------------------------------
# Instead of shipping raw XML files, embed them in shell heredocs within
# template files. This allows coral-tool-conf to use envsubst to substitute
# $PKGINSTROOT with the actual installation path at deployment time.
#
# Template format (example):
#   cat << 'EOF_TOOLFILE' >> $PKGINSTROOT/tools/selected/gcc.xml
#   <tool name="gcc" version="12.3.0">...</tool>
#   EOF_TOOLFILE

for type in selected available; do
    tmpl_file="$INSTALLROOT/tools/${type}.tmpl"
    type_dir="$INSTALLROOT/tools/${type}"

    # Reset/create the template file
    : > "$tmpl_file"

    # Skip if the directory doesn't exist
    [[ -d "$type_dir" ]] || continue

    # Process each XML file and embed it in a heredoc
    for xml in "$type_dir"/*.xml; do
        [[ -e "$xml" ]] || continue
        tool=$(basename "$xml")
        # Write heredoc that will recreate this XML file when executed
        {
            echo "cat << 'EOF_TOOLFILE' >> \$PKGINSTROOT/tools/${type}/${tool}"
            cat "$xml"
	    echo
            echo "EOF_TOOLFILE"
            echo
        } >> "$tmpl_file"
    done

    # Remove original XML directory - only templates are shipped
    # coral-tool-conf will regenerate the XMLs from templates
    rm -rf "$type_dir"
done
python3 $WORK_DIR/wrapper-scripts/resolve_meta.py $INSTALLROOT/tools/selected.tmpl | cpp -P -x assembler-with-cpp > /tmp/selected.tmpl && mv /tmp/selected.tmpl $INSTALLROOT/tools/selected.tmpl
python3 $WORK_DIR/wrapper-scripts/resolve_meta.py $INSTALLROOT/tools/available.tmpl | cpp -P -x assembler-with-cpp > /tmp/available.tmpl && mv /tmp/available.tmpl $INSTALLROOT/tools/available.tmpl
