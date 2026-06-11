package: coral
version: "CORAL_2_3_21"
variables:
  tag: "4fc6c24175682aff2d4299765b47b603a7b218d2"
  branch: "cms/CORAL_2_3_21py3"
  github_user: "cms-externals"
  subpackageDebug: "yes"
  configtag: "V09-08-10"
  buildtarget: "release-build"
  scram_compiler: "gcc"
  enable_biglib: "1"
  srctree: "src"
  bootstrapfile: "config/bootsrc.xml"
  package_vectorization: ""
  usercxxflags: ""
  scram_target_default: ""
  release_usercxxflags: ""
  release_userldflags: ""
  extra_tools: "Python"
  remove_tools: ""
  compile_options: ""
  nolibchecks: ""
  prebuildtarget: ""
  additionalBuildTarget0: ""
  postbuildtarget: ""
  ignore_compile_errors: ""
  pgo_generate: ""
  runGlimpse: ""
  saveDeps: ""
sources:
 - git+https://github.com/cms-sw/cmssw-config.git?obj=master/%(configtag)s&export=config&output=/cmssw-config-%(configtag)s.tgz
 - git+https://github.com/%(github_user)s/coral.git?protocol=https&obj=%(branch)s/%(tag)s&module=coral&export=%(srctree)s&output=/src.tar.gz
patches:
 - coral-2_3_21-gcc8.patch
 - coral-2_3_21-py312.patch
build_requires:
 - SCRAMV1
 - dwz
requires:
 - coral-tool-conf
 - pcre
 - Python
 - gcc
 - expat
 - boost
 - frontier_client
 - sqlite
 - libuuid
 - zlib
 - bz2lib
 - xerces-c
force_revision: ""
---
source $WORK_DIR/cmsset_default.sh
%(##INCLUDE:cms.bits/scram-project-build.sh)s
