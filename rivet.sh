package: rivet
version: 4.1.0
variables:
  override_microarch: ""
requires:
 - hepmc3
 - fastjet
 - fastjet-contrib
 - yoda
 - hdf5
 - highfive
 - microarch-flag
build_requires:
 - Python
 - py-cython
 - autotools
sources:
- git+https://gitlab.com/hepcedar/rivet.git?obj=master/%(package)s-%(version)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s.tgz
- file://scram-tools.file/tools/eigen/env.sh 
patches:
 - rivet-duplicate-libs.patch
 - rivet-pyextfjcontrib.patch
---
if [[ -z "%(override_microarch)s" ]]; then
  export selected_microarch="-march=$default_microarch_name"
else:
  export selected_microarch="%(override_microarch)s"
fi

tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"
source $SOURCEDIR/$SOURCE1

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/tmp"
mkdir -p "$TMPDIR"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
    ls -la "$TMPDIR"/config.{guess,sub}
else
    exit 1
fi
for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_GUESS_FILE"
    cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE"
    chmod +x "$CONFIG_GUESS_FILE"
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/tmp/*"); do
    rm -f "$CONFIG_SUB_FILE"
    cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE"
    chmod +x "$CONFIG_SUB_FILE"
done

autoreconf -fiv

if [[ "$(uname -m)" == "aarch64" ]]; then
  sed -i -e 's|^ax_openmp_flags=".*"|ax_openmp_flags="none"|' ./configure
fi
CXXFLAGS="-std=c++$CXXSTD $CMS_EIGEN_CXX_FLAGS $selected_microarch"
sed -i "/_pow10 only defined for positive powers/d" include/Rivet/Tools/ParticleIdUtils.hh

./configure --disable-silent-rules --prefix=$INSTALLROOT --with-hepmc=${HEPMC3_ROOT} \
            --with-fastjet=${FASTJET_ROOT} --with-fjcontrib=${FASTJET_CONTRIB_ROOT} --with-yoda=${YODA_ROOT} \
            --disable-doxygen --with-pic --enable-h5 \
            CXX="mpicxx" CPPFLAGS="-I${BOOST_ROOT}/include" CXXFLAGS="${CXXFLAGS}"

perl -p -i -e "s|LIBS = $|LIBS = -lHepMC3|g" bin/Makefile

make ${JOBS+-j $JOBS} all
make install
sed -i -e 's|^#!.*python.*|#!/usr/bin/env python3|' $INSTALLROOT/bin/*
