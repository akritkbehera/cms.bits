package: hdf5
version: "%(tag_basename)s"
tag: "hdf5_1.14.6"
source: https://github.com/HDFGroup/hdf5/
requires:
- zlib
- openmpi
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
rm -f $BUILDDIR/bin/config.guess
rm -f $BUILDDIR/bin/config.sub

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"

TMPDIR="$BUILDDIR/bin"
mkdir -p "$TMPDIR"

rm -f "$TMPDIR"/config.{sub,guess}

curl -L -k -s -o "$TMPDIR"/config.guess "$CONFIG_GUESS_URL"

curl -L -k -s -o "$TMPDIR"/config.sub "$CONFIG_SUB_URL"

ls -l "$TMPDIR"/config.*

if [[ -f "$TMPDIR/config.guess" && -f "$TMPDIR/config.sub" ]]; then
  ls -la "$TMPDIR"/config.{guess,sub}
else
  exit 1
fi
for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/bin/*"); do
  rm -f "$CONFIG_GUESS_FILE" || {
    echo "❌ Failed to remove $CONFIG_GUESS_FILE"
    exit 1
  }
  cp "$TMPDIR/config.guess" "$CONFIG_GUESS_FILE" || {
    echo "❌ Failed to copy config.guess to $CONFIG_GUESS_FILE"
    exit 1
  }
  chmod +x "$CONFIG_GUESS_FILE" || {
    echo "❌ Failed to chmod $CONFIG_GUESS_FILE"
    exit 1
  }
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/bin/*"); do
  rm -f "$CONFIG_SUB_FILE" || {
    echo "❌ Failed to remove $CONFIG_SUB_FILE"
    exit 1
  }
  cp "$TMPDIR/config.sub" "$CONFIG_SUB_FILE" || {
    echo "❌ Failed to copy config.sub to $CONFIG_SUB_FILE"
    exit 1
  }
  chmod +x "$CONFIG_SUB_FILE" || {
    echo "❌ Failed to chmod $CONFIG_SUB_FILE"
    exit 1
  }
done

CXXFLAGS=-I${OPENMPI_ROOT}/include \
  LDFLAGS="-L${OPENMPI_ROOT}/lib -lmpi" \
  ./configure --prefix $INSTALLROOT \
  --disable-sharedlib-rpath \
  --enable-parallel \
  --enable-threadsafe --enable-unsupported \
  --with-zlib=${ZLIB_ROOT}

make ${JOBS+-j $JOBS}
make install
