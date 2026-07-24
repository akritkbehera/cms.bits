package: fftjet
version: 1.5.0
sources:
- https://fftjet.hepforge.org/downloads/?f=fftjet-%(version)s.tar.gz
requires:
 - gcc
 - FFTW3
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

PLATF_CONF_OPTS="--enable-static --disable-shared"
F77="$(which gfortran) -fPIC"
CXX="$(which g++) -fPIC"
# Update to detect aarch64 and ppc64le
CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
rm -f "$BUILDDIR"/config.{sub,guess}
curl -L -k -s -o "$BUILDDIR"/config.guess "$CONFIG_BASE_URL/config.guess"
curl -L -k -s -o "$BUILDDIR"/config.sub "$CONFIG_BASE_URL/config.sub"
chmod +x "$BUILDDIR"/config.{sub,guess}
[[ -s "$BUILDDIR/config.guess" && -s "$BUILDDIR/config.sub" ]] || exit 1
touch pkg-config ; chmod +x pkg-config

configure_args=(
  $PLATF_CONF_OPTS
  --prefix="$INSTALLROOT"
  --disable-dependency-tracking
  --enable-threads
  F77="$F77"
  CXX="$CXX"
  DEPS_CFLAGS="-I$FFTW3_ROOT/include"
  DEPS_LIBS="-L$FFTW3_ROOT/lib -lfftw3" 
  PKG_CONFIG=$PWD/pkg-config
  )
if [[ -z $arch_build_flags ]]; then
  configure_args+=(
    CXXFLAGS="-O2"
    )
else
  configure_args+=(
    CXXFLAGS="$arch_build_flags -O2"
    )
fi

./configure "${configure_args[@]}"
make ${JOBS:+-j$JOBS}
make install

# Not required, and rpm builds used to grow a dependency on system pkg-config
rm -rf "$INSTALLROOT/lib/pkgconfig"
