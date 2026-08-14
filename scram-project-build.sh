#!/bin/bash
# scram-project-build.sh
# Template script — do not execute directly.
# Variables substituted by resolve_meta.py before execution.

# ---------------------------------------------------------------------------
# Block 1: Configurable — substituted by calling package
# ---------------------------------------------------------------------------
CONFIGTAG="%(configtag)s"
BUILDTARGET="%(buildtarget)s"
SCRAM_COMPILER="%(scram_compiler)s"
ENABLE_BIGLIB="%(enable_biglib)s"
SRCTREE="%(srctree)s"
BOOTSTRAPFILE="%(bootstrapfile)s"
SUBPACKAGE_DEBUG="%(subpackageDebug)s"
PACKAGE_VECTORIZATION="%(package_vectorization)s"
USERCXXFLAGS="%(usercxxflags)s"

# Derived — computed at runtime from environment
SCRAMV1_VERSION=$(basename "$SCRAMV1_ROOT")
SCRAMCMD="$SCRAMV1_ROOT/bin/scram -v --arch $ARCHITECTURE"
SCRAM_SCRIPT_PREFIX=".py"
# Extract base project type: CMSSW_20_1_X -> CMSSW, coral -> CORAL
UCPROJTYPE=$(echo "$PKGNAME" | sed -e 's|-patch||' -e 's|_[0-9].*||' | tr 'a-z' 'A-Z')
LCPROJTYPE=$(echo "$UCPROJTYPE" | tr 'A-Z' 'a-z')
TOOLCONF_VAR=$(echo "$PKGNAME" | sed 's|-|_|g' | tr 'a-z' 'A-Z')_TOOL_CONF_ROOT
TOOLCONF_PATH="${!TOOLCONF_VAR:-$CMSSW_TOOL_CONF_ROOT}"
CMSSW_LIBS="biglib/$ARCHITECTURE lib/$ARCHITECTURE"

# ---------------------------------------------------------------------------
# Block 2: extraOptions — three cases from spec
#   1. subpackageDebug on  → fdebug-prefix-map both cmsroot and instroot + -g
#   2. usercxxflags set    → pass through as USER_CXXFLAGS
#   3. neither             → empty
# cmsroot  = $WORK_DIR
# instroot = $WORK_DIR/$ARCHITECTURE
# ---------------------------------------------------------------------------
if [ "$SUBPACKAGE_DEBUG" != "0" ]; then
    EXTRA_CXXFLAGS="-fdebug-prefix-map=$WORK_DIR=$INSTALLROOT -fdebug-prefix-map=$WORK_DIR/$ARCHITECTURE=$INSTALLROOT -g${USERCXXFLAGS:+ $USERCXXFLAGS}"
elif [ -n "$USERCXXFLAGS" ]; then
    EXTRA_CXXFLAGS="$USERCXXFLAGS"
else
    EXTRA_CXXFLAGS=""
fi

# ---------------------------------------------------------------------------
# Block 3: PREP — config setup
# ---------------------------------------------------------------------------
#rm -rf "$BUILDDIR/poison"

if [ ! -f "$BUILDDIR/config/updateConfig.py" ]; then
  mkdir -p "$BUILDDIR/config"
  tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR/config"
fi


for i in 1 2 3; do
  src_var="SOURCE$i"
  if [ -n "${!src_var}" ] && [ -f "$SOURCEDIR/${!src_var}" ]; then
    mkdir -p "$BUILDDIR/src"
    tar -xzf "$SOURCEDIR/${!src_var}" --strip-components=1 -C "$BUILDDIR/src"
  fi
done

if [ "$PKGNAME" = "coral" ]; then
    pushd $BUILDDIR
    patch -p1 <$SOURCEDIR/$PATCH0
    patch -p1 <$SOURCEDIR/$PATCH1
    popd
fi

echo "$CONFIGTAG" > "$BUILDDIR/config/config_tag"

"$BUILDDIR/config/updateConfig.py" \
  -p "$UCPROJTYPE" \
  -v "${PKGVERSION}${PKGREVISION:+-$PKGREVISION}" \
  -s "$SCRAMV1_VERSION" \
  -t "$TOOLCONF_PATH" \
  --keys SCRAM_COMPILER="$SCRAM_COMPILER" \
  --keys PROJECT_GIT_HASH="${GITCOMMIT:-$PKGVERSION}" \

sed -i -e 's| SCRAM_TARGETS=.*"| SCRAM_TARGETS=""|' "$BUILDDIR/config/Self.xml"

if [ "$PKGNAME" != "coral" ]; then
  sed -i -e "s|</tool>| <runtime name=\"SCRAM_DEFAULT_MICROARCH\" value=\"$DEFAULT_MICROARCH_NAME\"/>\n</tool>|" \
    "$BUILDDIR/config/Self.xml"
fi

# ---------------------------------------------------------------------------
# Block 4: Vectorization Self.xml edits, release flags, SCRAM bootstrap
# ---------------------------------------------------------------------------
SCRAM_TARGET_DEFAULT="%(scram_target_default)s"
RELEASE_USERCXXFLAGS="%(release_usercxxflags)s"
RELEASE_USERLDFLAGS="%(release_userldflags)s"
##PACKAGE_VECTORIZATION="%(package_vectorization)s"
##if [ -z "$PACKAGE_VECTORIZATION" ] && [ -n "$SCRAM_TARGET_DEFAULT" ]; then
##  export SCRAM_TARGET_DEFAULT="auto"
##fi

if [ "$PKGNAME" != "coral" ] && [ "$PACKAGE_VECTORIZATION" != "0" ]; then
  if [ -e "$TOOLCONF_PATH/vectorized_packages.txt" ]; then
    sed -i -e "s| SCRAM_TARGETS=.*\"| SCRAM_TARGETS=\"$PACKAGE_VECTORIZATION\"|" \
      "$BUILDDIR/config/Self.xml"
    sed -i -e "s|</tool>| <runtime name=\"SCRAM_MIN_SUPPORTED_MICROARCH\" value=\"$DEFAULT_MICROARCH_NAME\"/>\n</tool>|" \
      "$BUILDDIR/config/Self.xml"
    sed -i -e "s|</tool>| <runtime name=\"SCRAM_TARGET\" value=\"$SCRAM_TARGET_DEFAULT\"/>\n <runtime name=\"USER_TARGETS_ALL\" value=\"1\"/>\n</tool>|" \
      "$BUILDDIR/config/Self.xml"
  fi
fi

[ -n "$RELEASE_USERCXXFLAGS" ] && \
  echo "<flags CXXFLAGS=\"$RELEASE_USERCXXFLAGS\"/>" >> "$BUILDDIR/config/BuildFile.xml"
[ -n "$RELEASE_USERLDFLAGS" ] && \
  echo "<flags LDFLAGS=\"$RELEASE_USERLDFLAGS\"/>" >> "$BUILDDIR/config/BuildFile.xml"

# Legacy RPM macros removed - patches are now applied via bits recipe 'patches:' field

$SCRAMCMD project -d "$(dirname "$INSTALLROOT")" -b "$BUILDDIR/$BOOTSTRAPFILE"
echo "$(basename "$SCRAMV1_ROOT")" > "$INSTALLROOT/config/scram_version"

# Populate src tree — scram bootstrap does not copy sources automatically
#if [ -d "$BUILDDIR/$SRCTREE" ]; then
#  rsync -a "$BUILDDIR/$SRCTREE/" "$INSTALLROOT/$SRCTREE/"
#fi
# ---------------------------------------------------------------------------
# Block 5: BUILD — pre-compile cleanup and tool setup
# ---------------------------------------------------------------------------
EXTRA_TOOLS="%(extra_tools)s"
REMOVE_TOOLS="%(remove_tools)s"

find "$INSTALLROOT/$SRCTREE" -type d -name cmt -exec rm -rf {} + 2>/dev/null || true

grep -r -l -e "^#!.*perl.*" "$INSTALLROOT/$SRCTREE" 2>/dev/null | \
  xargs -r perl -p -i -e 's|^#!.*perl(.*)|#!/usr/bin/env perl$1|' || true

# ---------------------------------------------------------------------------
# Tool-name compatibility patch (upstream cmsdist names -> this tree's names)
# ---------------------------------------------------------------------------
# CMSSW BuildFiles reference the upstream SCRAM tool names `python3` and
# `py3-<name>`, but this tree renamed its Python tools to `python` / `py-<name>`.
# Rewrite the tool references in every XML so scram resolves them natively.
# Matching is scoped to the name="..."/name='...' attribute VALUE so we do not
# corrupt lib names or version strings:
#   * py3-<x>  -> py-<x>      (prefix rewrite inside a name= value)
#   * python3  -> python      ONLY when it is the entire value, so
#                             <lib name="python3.12"/> is left untouched.
# Patch 1: py3-* -> py-*
# `grep -rl` exits 1 when nothing matches (e.g. coral, which has no py3-/python3 tool refs);
# the trailing `|| true` keeps that non-match from aborting the build under set -e/pipefail.
# `xargs -r` already skips sed entirely on empty input, so no file is touched when unmatched.
{ grep -rlZ --include='*.xml' -E "name=[\"']py3-" "$INSTALLROOT/$SRCTREE" 2>/dev/null || true; } | \
  xargs -0 -r sed -i -E "s/(name=[\"'])py3-/\1py-/g"
# Patch 2: python3 -> python (whole-value only)
{ grep -rlZ --include='*.xml' -E "name=[\"']python3[\"']" "$INSTALLROOT/$SRCTREE" 2>/dev/null || true; } | \
  xargs -0 -r sed -i -E "s/(name=[\"'])python3([\"'])/\1python\2/g"

$SCRAMCMD arch
cd "$INSTALLROOT/$SRCTREE"

[ "$ENABLE_BIGLIB" = "0" ] && { $SCRAMCMD build disable-biglib || true; }

for t in $EXTRA_TOOLS;  do $SCRAMCMD setup "$t";       done
for t in $REMOVE_TOOLS; do $SCRAMCMD tool remove "$t"; done

cat > "$INSTALLROOT/config/toolbox/$ARCHITECTURE/tools/selected/cmssw-config.xml" <<EOF
<tool name="cmssw-config" version="$CONFIGTAG" revision="1">
</tool>
EOF
$SCRAMCMD setup cmssw-config

export BUILD_LOG=yes
export SCRAM_NOPLUGINREFRESH=yes
$SCRAMCMD b clean

# ---------------------------------------------------------------------------
# Block 6: BUILD — compile
# ---------------------------------------------------------------------------
COMPILE_OPTIONS="%(compile_options)s"
NOLIBCHECKS="%(nolibchecks)s"
PREBUILDTARGET="%(prebuildtarget)s"
ADDITIONAL_BUILD_TARGET="%(additionalBuildTarget0)s"
POSTBUILDTARGET="%(postbuildtarget)s"
IGNORE_COMPILE_ERRORS="%(ignore_compile_errors)s"
PGO_GENERATE="%(pgo_generate)s"

[ "$NOLIBCHECKS" != "0" ] && { export SCRAM_NOLOADCHECK=true; export SCRAM_NOSYMCHECK=true; }

# Set up SCRAM runtime environment (LD_LIBRARY_PATH, PATH, etc.) before build
eval "$($SCRAMCMD runtime -sh)"
export LD_LIBRARY_PATH

$SCRAMCMD b -r echo_CXX </dev/null

[ -n "$PREBUILDTARGET" ] && $SCRAMCMD b --verbose -f "$PREBUILDTARGET" </dev/null

# llvm-ccdb only for cmssw/cmssw-patch, skipped during PGO generate phase
if [ "$PGO_GENERATE" = "0" ]; then
  case "$PKGNAME" in cmssw|cmssw-patch)
    $SCRAMCMD b -f -k ${JOBS:+-j $JOBS} llvm-ccdb </dev/null || true ;;
  esac
fi

grep -q 'name="SCRAM_TARGET"' "$INSTALLROOT/config/Self.xml" && \
  touch "$INSTALLROOT/.SCRAM/$ARCHITECTURE/multi-targets"

SCRAM_B_EXTRA=()
[ -n "$EXTRA_CXXFLAGS" ] && SCRAM_B_EXTRA=("USER_CXXFLAGS=$EXTRA_CXXFLAGS")

$SCRAMCMD b --verbose -f $COMPILE_OPTIONS "${SCRAM_B_EXTRA[@]}" ${JOBS:+-j $JOBS} "$BUILDTARGET" </dev/null || {
  touch "$BUILDDIR/build-errors"
  $SCRAMCMD b -f outputlog || true
  [ "$IGNORE_COMPILE_ERRORS" != "0" ] || exit 1
}

[ -n "$ADDITIONAL_BUILD_TARGET" ] && $SCRAMCMD b --verbose -f "$ADDITIONAL_BUILD_TARGET" </dev/null
[ -n "$POSTBUILDTARGET" ]         && $SCRAMCMD b --verbose -f "$POSTBUILDTARGET"          </dev/null

# Move logs out so they don't get packaged
LOG_WEB_DIR="$WORK_DIR/WEB/build-logs/$ARCHITECTURE/$PKGVERSION"
rm -rf "$LOG_WEB_DIR"
mkdir -p "$LOG_WEB_DIR/logs/src"
if [ -d "$INSTALLROOT/tmp/$ARCHITECTURE/cache/log/src" ]; then
  tar czf "$LOG_WEB_DIR/logs/src/src-logs.tgz" \
    -C "$INSTALLROOT/tmp/$ARCHITECTURE/cache/log/src" ./
fi

# ---------------------------------------------------------------------------
# Block 7: saveDeps + edmPluginRefresh
# ---------------------------------------------------------------------------
SAVEDEPS="%(saveDeps)s"

if [ "$SAVEDEPS" != "0" ]; then
  mkdir -p "$INSTALLROOT/etc/dependencies"
  SCRAM_TOOL_HOME="$SCRAMV1_ROOT" \
    "$INSTALLROOT/config/SCRAM/findDependencies.py" \
    -rel "$INSTALLROOT" -arch "$ARCHITECTURE"
  gzip -f "$INSTALLROOT/etc/dependencies/"*.out
fi

eval "$(USER_SCRAM_RUNTIME_TYPE=BUILD $SCRAMCMD run -sh)"

cmdpath=$(command -v edmPluginRefresh 2>/dev/null || true)
if [ -n "$cmdpath" ]; then
  for lib in $CMSSW_LIBS; do
    [ -d "$INSTALLROOT/$lib" ] || continue
    rm -f "$INSTALLROOT/$lib/.edmplugincache"
    edmPluginRefresh "$INSTALLROOT/$lib"
    if [ "$PACKAGE_VECTORIZATION" != "0" ]; then
      for arch in $PACKAGE_VECTORIZATION; do
        arch_dir="$INSTALLROOT/$lib/scram_${arch}"
        [ -d "$arch_dir" ] || continue
        rm -f "$arch_dir/.edmplugincache"
        [ -e "$INSTALLROOT/$lib/.edmplugincache" ] && \
          cp "$INSTALLROOT/$lib/.edmplugincache" "$arch_dir/.edmplugincache"
      done
    fi
  done
fi

# ---------------------------------------------------------------------------
# Block 8: INSTALL
# ---------------------------------------------------------------------------
RUNGLIMPSE="%(runGlimpse)s"

export SCRAM_ARCH="$ARCHITECTURE"
cd "$INSTALLROOT"

$SCRAMCMD install -f

rm -rf "external/$ARCHITECTURE"
SCRAM_TOOL_HOME="$SCRAMV1_ROOT" \
  ./config/SCRAM/linkexternal${SCRAM_SCRIPT_PREFIX} --arch "$ARCHITECTURE"

[ "$RUNGLIMPSE" != "0" ] && $SCRAMCMD b --verbose -f gindices </dev/null

tar czf "${SRCTREE}.tar.gz" "$SRCTREE"
rm -rf "$SRCTREE" tmp

if [ "$SUBPACKAGE_DEBUG" != "0" ]; then
  touch "$INSTALLROOT/.SCRAM/$ARCHITECTURE/subpackage-debug"

  if [ "$PKGNAME" = "coral" ]; then
    ELF_DIRS="$INSTALLROOT/$ARCHITECTURE/lib $INSTALLROOT/$ARCHITECTURE/tests/bin"
    DROP_SYMBOLS_DIRS=""
  else
    ELF_DIRS="$INSTALLROOT/lib/$ARCHITECTURE $INSTALLROOT/biglib/$ARCHITECTURE $INSTALLROOT/bin/$ARCHITECTURE $INSTALLROOT/test/$ARCHITECTURE"
    DROP_SYMBOLS_DIRS="$INSTALLROOT/objs/$ARCHITECTURE"
  fi

  for DIR in $ELF_DIRS $DROP_SYMBOLS_DIRS; do
    [ -d "$DIR" ] || continue
    pushd "$DIR"
    mkdir -p .debug
    ELF_BINS=$(file * 2>/dev/null | grep ELF | cut -d':' -f1 || true)
    if [ -n "$ELF_BINS" ]; then
      [ $(echo $ELF_BINS | wc -w) -gt 1 ] && \
        dwz -m .debug/common-symbols.debug -M common-symbols.debug $ELF_BINS || true
      echo "$ELF_BINS" | xargs -t -n1 -P${JOBS:-1} -I%% sh -c \
        'objcopy --compress-debug-sections --only-keep-debug %% .debug/%%.debug
         objcopy --strip-debug --add-gnu-debuglink=.debug/%%.debug %%'
    fi
    popd
  done

  for DIR in $DROP_SYMBOLS_DIRS; do
    rm -rf "$DIR/.debug"
  done
fi

# ---------------------------------------------------------------------------
# Block 9: Symlink relocation + stored runtime values
# ---------------------------------------------------------------------------
for L in $(find "external/$ARCHITECTURE" -type l 2>/dev/null); do
  lnk=$(readlink -n "$L" 2>&1 || true)
  case "$lnk" in
    "$WORK_DIR"/*)
      rl=$(echo "$L" | sed -e 's|[^/]*/|../|g' | xargs dirname)
      al=$(echo "$lnk" | sed -e "s|^$WORK_DIR/|../../../../$rl/|")
      rm -f "$L"
      ln -sf "$al" "$L"
      ;;
  esac
done

find "external/$ARCHITECTURE" -type l 2>/dev/null | xargs ls -l || true

echo "$WORK_DIR"             > "$INSTALLROOT/config/scram_basedir"
echo "$SCRAM_TARGET_DEFAULT" > "$INSTALLROOT/.SCRAM/$ARCHITECTURE/scram_target_default"

# ---------------------------------------------------------------------------
# Block 10: Post-relocate script
# ---------------------------------------------------------------------------
mkdir -p "$INSTALLROOT/etc/profile.d"
cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" << 'POSTRELOCATE_EOF'
#!/bin/bash
PKG_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PKG_ROOT"
export SCRAM_ARCH="$ARCHITECTURE"

if [ -e src.tar.gz ]; then
  tar xzf src.tar.gz
  rm -f src.tar.gz
fi

OLD_WORK_DIR=$(cat config/scram_basedir)

# Only rename paths from OLD_WORK_DIR to WORK_DIR (for cross-machine relocation)
# Do NOT strip architecture from paths - external tools need the full arch path
./config/SCRAM/projectAreaRename.py "$OLD_WORK_DIR" "$WORK_DIR" "$SCRAM_ARCH"

for lib in biglib/$SCRAM_ARCH lib/$SCRAM_ARCH; do
  [ -f "$lib/.edmplugincache" ] || continue
  find "$lib" -name "*.edmplugin" -type f -exec touch {} \;
  touch "$lib/.edmplugincache"
  for arch_dir in "$lib"/scram_*/; do
    [ -f "$arch_dir/.edmplugincache" ] || continue
    find "$arch_dir" -name "*.edmplugin" -type f -exec touch {} \;
    touch "$arch_dir/.edmplugincache"
  done
done

sed -i "s|$OLD_WORK_DIR|$WORK_DIR|g" "external/$SCRAM_ARCH/links.DB" 2>/dev/null || true
[ -f compile_commands.json ] && sed -i "s|$OLD_WORK_DIR|$WORK_DIR|g" compile_commands.json

# Extract base project name: CMSSW_20_1_X -> CMSSW, coral -> CORAL, cmssw-patch -> CMSSW
UCPROJ=$(echo "$PKGNAME" | sed -e 's|-patch||' -e 's|_[0-9].*||' | tr 'a-z' 'A-Z')
LCPROJ=$(echo "$UCPROJ" | tr 'A-Z' 'a-z')
SCRAMRC_DIR="$WORK_DIR/etc/scramrc"
# Use lowercase project name for map filename (cmssw.map, coral.map)
if [ ! -f "$SCRAMRC_DIR/${LCPROJ}.map" ]; then
  mkdir -p "$SCRAMRC_DIR"
  echo "${UCPROJ}=\$SCRAM_ARCH/cms/${PKGNAME}/${UCPROJ}_*" > "$SCRAMRC_DIR/${LCPROJ}.map"
fi

SITE_CFG="$WORK_DIR/etc/scramrc/site.cfg"
if [ -e "$SITE_CFG" ]; then
  if [ -e ".SCRAM/$SCRAM_ARCH/multi-targets" ]; then
    SCRAM_TARGET_DEFAULT=$(cat ".SCRAM/$SCRAM_ARCH/scram_target_default" 2>/dev/null || echo "auto")
    site_target=$(grep '^\s*scram-target\s*=' "$SITE_CFG" | sed 's| ||g;s|.*=||')
    if [ -n "$site_target" ] && [ "$site_target" != "none" ] && [ "$site_target" != "$SCRAM_TARGET_DEFAULT" ]; then
      sed -i -e "/=\"SCRAM_TARGET\"/s/\"$SCRAM_TARGET_DEFAULT\"/\"$site_target\"/" config/Self.xml
      "$WORK_DIR/common/scram" setup self
    fi
  fi
  for type in scram "$LCPROJ"; do
    script=$(grep "^\s*${type}-post-install-script\s*=" "$SITE_CFG" | sed 's| ||g;s|.*=||')
    if [ -n "$script" ] && [ -x "$script" ]; then
      "$script" "$SCRAM_ARCH"
    fi
  done
fi
POSTRELOCATE_EOF

chmod +x "$INSTALLROOT/etc/profile.d/post-relocate.sh"
