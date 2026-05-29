package: coral-new
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
sources:
 - git+https://github.com/cms-sw/cmssw-config.git?obj=master/%(configtag)s&export=config&output=/cmssw-config-%(configtag)s.tgz
 - git+https://github.com/%(github_user)s/coral.git?protocol=https&obj=%(branch)s/%(tag)s&module=coral&export=%(srctree)s&output=/src.tar.gz
 - file://scram-project-build.sh
patches:
 - coral-2_3_21-gcc8.patch
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
python3 resolve_meta.py $SOURCEDIR/scram-project-build.sh &> $BUILDDIR/scram-project-build.sh
