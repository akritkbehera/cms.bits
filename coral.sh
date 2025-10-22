package:           coral
version:           "CORAL_2_3_21"
variables:
  tag:             "4fc6c24175682aff2d4299765b47b603a7b218d2"
  branch:          "cms/CORAL_2_3_21py3"
  github_user:     "cms-externals"
  subpackageDebug: "yes"
  srctree:         "src"
  configtag:       "V09-08-10"
sources:
 - git+https://github.com/cms-sw/cmssw-config.git?obj=master/%(configtag)s&export=config&output=/cmssw-config-%(configtag)s.tgz
 - git://github.com/%(github_user)s/%(package)s.git?protocol=https&obj=%(branch)s/%(tag)s&module=%(package)s&export=%(srctree)s&output=/src.tar.gz
patches:
 - coral-2_3_20-macosx.patch
 - coral-2_3_21-gcc8.patch
build_requires:
 - SCRAMV1
requires:
 - coral-tools
 - pcre
 - Python
 - gcc
 - expat
 - boost
 - frontier-client
 - sqlite
 - libuuid
 - zlib
 - bz2lib
 - xerces-c
---
echo $SOURCEDIR
tar -xzf "$SOURCEDIR/${SOURCE0}" -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/${SOURCE1}" -C "$BUILDDIR"

scram_patches() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    patchsrc2="perl -p -i -e 's!(<classpath.*/tests\\+.*>)!!;' config/BuildFile.xml"
    patchsrc3='patch -p1 -s -i "$SOURCEDIR/$PATCH0"'
  fi

  if [[ "$(uname -m)" == "x86_64" ]]; then
    patchsrc2='rm -rf ./src/OracleAccess'
  fi

  patchsrc4='patch -p1 -s -i "$SOURCEDIR/$PATCH1"'
}

source scram-project-build.sh
