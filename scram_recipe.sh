tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR/"

export cmssw_libs="biglib/$ARCHITECTURE lib/$ARCHITECTURE"
export srctree="src"
bootstrapfile="config/bootsrc.xml"

: "${enable_biglib:=1}"
: "${buildtarget:=release-build}"
: "${scram_compiler:=gcc}"
: "${configtag:=V09-08-10}"
: "${buildarch=:}"
: "${ucprojtype:=$(echo "$PKGNAME" | sed -e 's|-patch||' | tr 'a-z' 'A-Z')}"
lcprojtype=$(echo "$ucprojtype" | tr 'A-Z' 'a-z')
: "${toolconf:=$(echo "$PKGNAME" | sed 's|-|_|g' | tr 'a-z' 'A-Z')_TOOL_CONF_ROOT}"


if [ -n "${package_vectorization:-}" ]; then
  : "${scram_target_default:=auto}"
fi

scramcmd="$SCRAMV1_ROOT/bin/scram --arch $ARCHITECTURE"
rm -rf config $srctree poison

cd $BUILDDIR
echo $configtag > $BUILDDIR/config/config_tag
$BUILDDIR/config/updateConfig.py -p $ucprojtype -v $PKG_VERSION -c -s $SCRAMV1_VERSION -t $toolconf \
  --keys SCRAM_COMPILER=$scram_compiler \
  --keys ENABLE_LTO=${enable_lto:-0} \
  --keys PROJECT_GIT_HASH=%(version)s \
  --keys ENABLE_PGO=${enable_pgo:-0} \

sed -i -e 's| SCRAM_TARGETS=.*"| SCRAM_TARGETS=""|' $BUILDDIR/config/Self.xml

if [ "$PKGNAME" != "coral" ]; then
  if [ -e $toolconf/vectorized_packages.txt ] ; then
    sed -i -e s| SCRAM_TARGETS=.*"| SCRAM_TARGETS=$package_vectorization| $BUILDDIR/config/Self.xml
    sed -i -e s|</tool>| <runtime name="SCRAM_MIN_SUPPORTED_MICROARCH" value="${default_microarch_name}"/>\n</tool>| $BUILDDIR/config/Self.xml
    sed -i -e s|</tool>| <runtime name="SCRAM_TARGET" value="${scram_target_default}"/>\n <runtime name="USER_TARGETS_ALL" value="1"/>\n</tool>| $BUILDDIR/config/Self.xml
  fi
fi

if [ -n "${release_usercxxflags:-}" ]; then
  echo "<flags CXXFLAGS=\"$release_usercxxflags\"/>" >> "$BUILDDIR/config/BuildFile.xml"
fi

if [ -n "${release_userldflags:-}" ]; then
  echo "<flags LDFLAGS=\"$release_userldflags\"/>" >> "$BUILDDIR/config/BuildFile.xml"
fi

[ -n "${PartialBootstrapPatch:-}" ] && eval "$PartialBootstrapPatch"
scram_patches()

[ -n "${buildarch:-}" ] && echo "$buildarch"

$scramcmd project -d $INSTALLROOT -b $bootstrapfile

if [ -n "${pgo_build_flags:-}" ]; then
  sed -i -e "s|@LOCALTOP@|$INSTALLROOT|" \
    "$INSTALLROOT/config/toolbox/$ARCHITECTURE/tools/selected/gcc-cxxcompiler.xml"
fi

rm -rf `find $INSTALLROOT/$srctree -type d -name cmt`
grep -r -l -e "^#!.*perl.*" $INSTALLROOT/$srctree | xargs perl -p -i -e "s|^#!.*perl(.*)|#!/usr/bin/env perl\$1|"

$scramcmd arch
cd $INSTALLROOT/$srctree
if [ $enable_biglib -eq 0 ]; then
  $scramcmd build disable-biglib || true
fi
[ -n "${extra_tools:-}" ] && for t in $extra_tools; do
  $scramcmd setup "$t"
done

[ -n "${remove_tools:-}" ] && for t in $remove_tools; do
  $scramcmd tool remove "$t"
done

echo -e "<tool name=\"cmssw-config\" version=$configtag revision=\"1\">\n</tool>" \
          >> $INSTALLROOT/config/toolbox/$ARCHITECTURE/tools/selected/cmssw-config.xml
$scramcmd setup cmssw-config $buildarch
export BUILD_LOG=yes
export SCRAM_NOPLUGINREFRESH=yes
$scramcmd b clean
if [[ "$(uname -s)" == "Darwin" ]]; then
  $scramcmd b echo_null
  eval `$scramcmd runtime -sh`
fi
if [ -n "${nolibchecks:-}" ]; then
  export SCRAM_NOLOADCHECK=true
  export SCRAM_NOSYMCHECK=true
fi

[ -n "${preBuildCommand:-}" ] && eval "$preBuildCommand"
$scramcmd b -r echo_CXX </dev/null

[ -n "${prebuildtarget:-}" ] && $scramcmd b --verbose -f "$prebuildtarget" </dev/null
[ -z "${pgo_generate:-}" ] && case "$PKGNAME" in
  cmssw|cmssw-patch) $scramcmd b -f -k "${JOBS:+-j$JOBS}" llvm-ccdb </dev/null || true ;;
esac
if grep 'name="SCRAM_TARGET"' "$INSTALLROOT/config/Self.xml"; then
  touch "$INSTALLROOT/.SCRAM/$ARCHITECTURE/multi-targets"
fi

$scramcmd b --verbose -f ${compileOptions} ${extraOptions} ${JOBS:+-j$JOBS} ${buildtarget} </dev/null || { touch ../build-errors && $scramcmd b -f outputlog && [ "${?ignore_compile_errors:set}" == "set" ]; }

[ -n "${additionalBuildTarget0:-}" ] && $scramcmd b --verbose -f "$additionalBuildTarget0" </dev/null
[ -n "${postbuildtarget:-}" ] && $scramcmd b --verbose -f "$postbuildtarget" </dev/null

if [ -n "${saveDeps:-}" ]; then
  mkdir -p "$INSTALLROOT/etc/dependencies"
  SCRAM_TOOL_HOME="$SCRAMV1_ROOT${scram_home_suffix}" \
    "$INSTALLROOT/config/SCRAM/findDependencies${scram_script_prefix}" -rel "$INSTALLROOT" -arch "$ARCHITECTURE"
  [ -n "${PatchReleaseDependencyInfo:-}" ] && eval "$PatchReleaseDependencyInfo"
  gzip -f "$INSTALLROOT/etc/dependencies/"*.out
fi

eval `$scramcmd run -sh`
for cmd in edmPluginRefresh ; do
  cmdpath=`which $cmd 2> /dev/null || echo ""`

