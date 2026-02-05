package: cms-common
tag: a9321840d2b6bdefae0376d0aa8236e650290b19
source: https://github.com/cms-sw/cms-common
variables:
 revision: "1256"
version: "%(revision)s"
force_architecture: share
force_revision: ""
hook: disable
---
# Copy source tree to build directory, excluding git metadata.
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

# Substitute CMS install prefix and architecture in all source files.
# @CMS_PREFIX@ is replaced with the global install root (not the package dir).
# @SCRAM_ARCH@ is replaced with the architecture string.
find . -type f | xargs sed -i -e "s|@CMS_PREFIX@|$WORK_DIR|g;s|@SCRAM_ARCH@|$ARCHITECTURE|"

# Install all built files into the package directory.
rsync -a $BUILDDIR/ $INSTALLROOT/

# --- Post-relocate script ---
# cms-common files are deployed to the root of the install area ($WORK_DIR).
# This script copies package contents there, handling revision checks and
# special directories (scramrc, share).
cat >"$INSTALLROOT/etc/profile.d/post-relocate.sh" <<EoF
# Check if a newer revision is already installed.
# Also force installation if older revision has deleted cmsset_default.csh.
if [ -f \$WORK_DIR/cmsset_default.csh ] && [ -f \$WORK_DIR/etc/cms-common/revision ] ; then
  existing_rev=\$(cat \$WORK_DIR/etc/cms-common/revision)
  if [ \$existing_rev -ge %(revision)s ] ; then
    exit 0
  fi
fi

mkdir -p \$WORK_DIR/etc/cms-common \$WORK_DIR/share/etc/profile.d

# Enter the installed package directory to use relative paths for file operations.
cd \$WORK_DIR/share/$PKGNAME/$PKGVERSION

mkdir -p \$WORK_DIR/share \$WORK_DIR/etc/scramrc
# Sync SCRAM configuration database if present.
[ -d ./etc/scramrc/SCRAM ] && rsync -a --delete ./etc/scramrc/SCRAM/ \$WORK_DIR/etc/scramrc/SCRAM/
# Sync shared data files if present.
[ -d ./share ] && rsync -a ./share/ \$WORK_DIR/share/

# Copy all remaining files to the install root, skipping the scramrc/SCRAM
# directory (already handled above with --delete).
for file in \$(find . -name '*' | grep -v '^./etc/scramrc/SCRAM'); do
  if [ -d \$file ] ; then
    mkdir -p \$WORK_DIR/\$file
  else
    rm -f \$WORK_DIR/\$file
    cp -P \$file \$WORK_DIR/\$file
  fi
done

# Record the installed revision for future upgrade checks.
echo %(revision)s > \$WORK_DIR/etc/cms-common/revision
EoF

