package: expat
version: "2.7.1"
requires:
 - gcc
build_requires:
 - gmake
sources:
  - https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

CONFIG_BASE_URL="http://cmsrep.cern.ch/cmssw/download/config"
CONFIG_GUESS_URL="${CONFIG_BASE_URL}/config.guess"
CONFIG_SUB_URL="${CONFIG_BASE_URL}/config.sub"
CONFIG_DIR="$BUILDDIR/conftools"
rm -f "$CONFIG_DIR"/config.{sub,guess}
curl -L -k -s -o "$CONFIG_DIR"/config.guess "$CONFIG_GUESS_URL"
curl -L -k -s -o "$CONFIG_DIR"/config.sub "$CONFIG_SUB_URL"
chmod +x "$CONFIG_DIR"/config.{guess,sub}

if [[ -f "$CONFIG_DIR/config.guess" && -f "$CONFIG_DIR/config.sub" ]]; then
    ls -la "$CONFIG_DIR"/config.{guess,sub}
else
    exit 1
fi

for CONFIG_GUESS_FILE in $(find "$BUILDDIR" -name 'config.guess' -not -path "*/conftools/*"); do
    rm -f "$CONFIG_GUESS_FILE" || { echo "❌ Failed to remove $CONFIG_GUESS_FILE"; exit 1; }
    cp "$CONFIG_DIR/config.guess" "$CONFIG_GUESS_FILE" || { echo "❌ Failed to copy config.guess to $CONFIG_GUESS_FILE"; exit 1; }
    chmod +x "$CONFIG_GUESS_FILE" || { echo "❌ Failed to chmod $CONFIG_GUESS_FILE"; exit 1; }
done

for CONFIG_SUB_FILE in $(find "$BUILDDIR" -name 'config.sub' -not -path "*/conftools/*"); do
    echo "  📝 Replacing: $CONFIG_SUB_FILE"
    rm -f "$CONFIG_SUB_FILE" || { echo "❌ Failed to remove $CONFIG_SUB_FILE"; exit 1; }
    cp "$CONFIG_DIR/config.sub" "$CONFIG_SUB_FILE" || { echo "❌ Failed to copy config.sub to $CONFIG_SUB_FILE"; exit 1; }
    chmod +x "$CONFIG_SUB_FILE" || { echo "❌ Failed to chmod $CONFIG_SUB_FILE"; exit 1; }
done


cd "$BUILDDIR"
./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j $JOBS}

make install


# Mirror CMSBUILD default archive cleanup for this recipe.
rm -f "$INSTALLROOT"/lib/*.a "$INSTALLROOT"/lib/*.la
