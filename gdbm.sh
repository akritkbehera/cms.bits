package: gdbm
version: "1.26"
sources:
- http://ftp.gnu.org/gnu/gdbm/gdbm-%(version)s.tar.gz
build_requires:
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# Update to detect aarch64 and ppc64le
CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
rm -f "$BUILDDIR/build-aux"/config.{sub,guess}
curl -L -k -s -o "$BUILDDIR/build-aux/config.guess" "$CONFIG_BASE_URL/config.guess"
curl -L -k -s -o "$BUILDDIR/build-aux/config.sub" "$CONFIG_BASE_URL/config.sub"
chmod +x "$BUILDDIR/build-aux"/config.{sub,guess}
[[ -s "$BUILDDIR/build-aux/config.guess" && -s "$BUILDDIR/build-aux/config.sub" ]] || exit 1

cd "$BUILDDIR"
./configure \
  --enable-libgdbm-compat \
  --prefix="$INSTALLROOT" \
  --disable-dependency-tracking \
  --disable-nls \
  --disable-rpath

make ${JOBS:+-j$JOBS}
make install
