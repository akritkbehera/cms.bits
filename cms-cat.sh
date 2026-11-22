package: cms-cat
version: "250627.0"
variables: 
  commit: 5cf28195a12d7c98bfccdb36a5fffa7b36247af5
  branch: master
sources:
  - git://gitlab.cern.ch/cms-analysis/services/cms.cern.ch-cat.git?obj=%(branch)s/%(commit)s&export=cms-cat&output=/cms-cat-%(commit)s.tgz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p $INSTALLROOT/cat
mv * $INSTALLROOT/cat

# Install the shared catalog once per date revision.
mkdir -p "$INSTALLROOT/etc/profile.d"
cat > "$INSTALLROOT/etc/profile.d/post-relocate.sh" <<'EOF'
set -e
revision=%(version)s
revision=${revision%%.*}
stamp="$WORK_DIR/etc/cms-cat/version"
mkdir -p "$WORK_DIR/cat" "$(dirname -- "$stamp")"
if [ ! -f "$stamp" ] || [ "$(cat "$stamp")" -lt "$revision" ]; then
    rsync -a --delete "$WORK_DIR/$PP/cat/" "$WORK_DIR/cat/"
    printf '%%s\n' "$revision" > "$stamp"
fi
EOF
