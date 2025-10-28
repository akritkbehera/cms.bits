package: coral-tool-conf
version: vCMS
requires:
 - coral-tools
---
mkdir -p $INSTALLROOT/tools/{available,selected}
rsync -a $CORAL_TOOLS_ROOT/lib $INSTALLROOT/
# Step 1: Replace variables in template
export PKGINSTROOT=$INSTALLROOT
envsubst '$PKGINSTROOT' < $CORAL_TOOLS_ROOT/tools/selected.tmpl > $INSTALLROOT/tools/template.tmpl
# Step 2: Execute the script to generate XML files
bash $INSTALLROOT/tools/template.tmpl
envsubst '$PKGINSTROOT' < $CORAL_TOOLS_ROOT/tools/available.tmpl > $INSTALLROOT/tools/template.tmpl
bash $INSTALLROOT/tools/template.tmpl
