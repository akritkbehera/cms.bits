package: cmssw
version: "CMSSW_14_2_0"
variables:
  branch: "master"
  configtag: "V09-09-03"
  subpackageDebug: "yes"
  saveDeps: "yes"
  runGlimpse: "yes"
  buildtarget: "release-build"
  scram_compiler: "gcc"
  enable_biglib: "1"
  srctree: "src"
  bootstrapfile: "config/bootsrc.xml"
  skipreqtools: jcompiler rivet2 opencl opencl-cpp intel-vtune icx-cxxcompiler icx-ccompiler icx-f77compiler mpich
sources:
 - git+https://github.com/cms-sw/cmssw-config.git?obj=master/%(configtag)s&export=config&output=/cmssw-config-%(configtag)s.tgz
 - git+https://github.com/cms-sw/cmssw.git?protocol=https&obj=%(branch)s/%(version)s&module=CMSSW&export=%(srctree)s&output=/src.tar.gz
build_requires:
 - SCRAMV1
 - dwz
requires:
 - cmssw-tool-conf
---
# Extract coral source first so patches can be applied before template runs
tar -xzf "$SOURCEDIR/src.tar.gz" -C "$BUILDDIR"
python3 $WORK_DIR/wrapper-scripts/resolve_meta.py $BITS_CONFIG_DIR/scram-project-build.sh > $BUILDDIR/scram-build.sh
chmod +x $BUILDDIR/scram-build.sh
source $WORK_DIR/cmsset_default.sh
bash $BUILDDIR/scram-build.sh 2>&1 | tee $BUILDROOT/scram.log; exit ${PIPESTATUS[0]}
