package: thepeg
version: "2.2.2"
sources:
 - https://thepeg.hepforge.org/downloads/?f=ThePEG-%(version)s.tar.bz2
patches:
 - LHEEventNum.patch
 - thepeg-deprecated-warn.patch
 - thepeg-cpp23.patch
build_requires:
 - autotools
 - lhapdf
requires:
 - gcc
 - lhapdf
 - GSL
 - OpenBLAS
 - hepmc
 - zlib
 - fastjet
prepend_path:
  LD_LIBRARY_PATH: $THEPEG_ROOT/lib/ThePEG
  DYLD_LIBRARY_PATH: $THEPEG_ROOT/lib/ThePEG
---
tar -xjf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"
patch -p1 < "$SOURCEDIR/$PATCH2"
autoreconf -fiv

export CXX="$(which g++) -fPIC"
export CC="$(which gcc) -fPIC"
PLATF_CONF_OPTS="--enable-shared --disable-static"

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
TMPDIR="$BUILDDIR/Config"
rm -f "$TMPDIR"/config.{sub,guess}
curl -L -k -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"
chmod +x "$TMPDIR"/config.{sub,guess}

sed -i -e "s|-lgslcblas|-lopenblas|" ./configure
COMPILE_FLAGS="-g0 -O2 -DNDEBUG -std=c++$CXXSTD"
./configure $PLATF_CONF_OPTS \
            --with-lhapdf=$LHAPDF_ROOT \
            --with-boost=$BOOST_ROOT \
            --with-hepmc=$HEPMC_ROOT \
            --with-gsl=$GSL_ROOT \
            --with-zlib=$ZLIB_ROOT \
            --with-fastjet=$FASTJET_ROOT \
            --without-javagui \
            --prefix=$INSTALLROOT \
            --disable-readline CXX="$CXX" CC="$CC" LDFLAGS="-L${OPENBLAS_ROOT}/lib" CXXFLAGS="${COMPILE_FLAGS}" CFLAGS="${COMPILE_FLAGS}"

make ${JOBS:+-j$JOBS} V=1
make install
find $INSTALLROOT/lib -name '*.la' -exec rm -f {} \;

# create link to LesHouches library
cd $INSTALLROOT/lib/ThePEG/
ln -s LesHouches.so libLesHouches.so

