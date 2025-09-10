package: sherpa
version: "2.2.15"
sources:
 - http://www.hepforge.org/archive/sherpa/SHERPA-MC-%(version)s.tar.gz
patches:
 - sherpa-2.2.10-hepmcshort.patch
 - sherpa-cpp20.patch
build_requires:
 - mcfm
 - autotools
requires:
 - swig
 - hepmc
 - lhapdf
 - blackhat
 - sqlite
 - Python
 - fastjet
 - openmpi
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

autoreconf -i --force

if [[ $(uname -m) =~ ^x86_64.*$ ]]; then
	ARCH_CMSPLATF="-m64"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  perl -p -i -e 's|-rdynamic||g' \
    "configure" "AddOns/Analysis/Scripts/Makefile.in"
fi

patch -p1 < "$SOURCEDIR/$PATCH0"
patch -p1 < "$SOURCEDIR/$PATCH1"

export PYTHON=$(which python3)

./configure --prefix=$INSTALLROOT --enable-analysis --disable-silent-rules \
            --enable-fastjet=$FASTJET_ROOT \
            --enable-hepmc2=$HEPMC_ROOT \
            --enable-lhapdf=$LHAPDF_ROOT \
            --enable-blackhat=$BLACKHAT_ROOT \
            --enable-pyext \
            --enable-ufo \
            ${OPENLOOPS_ROOT+--enable-openloops=$OPENLOOPS_ROOT} \
            --enable-mpi \
            --with-sqlite3=$SQLITE_ROOT \
            --enable-analysis \
            CC="mpicc" \
            CXX="mpicxx" \
            MPICXX="mpicxx" \
            FC="mpifort" \
            CXXFLAGS="-fuse-cxa-atexit $ARCH_CMSPLATF -O2 -std=c++0x -I$LHAPDF_ROOT/include -I$BLACKHAT_ROOT/include -I$RIVET_ROOT/include" \
            LDFLAGS="-ldl -L$BLACKHAT_ROOT/lib/blackhat -L$QD_ROOT/lib"

make ${JOBS+-j $JOBS}
make install

find $INSTALLROOT/lib -name '*.la' -delete
sed -i -e 's|^#!/.*|#!/usr/bin/env python3|' $INSTALLROOT/bin/Sherpa-generate-model
