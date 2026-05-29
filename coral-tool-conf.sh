package: coral-tool-conf
version: vCMS
requires:
 - coral-tools
---
# =============================================================================
# coral-tool-conf: Deploys tool configuration files from coral-tools templates
# =============================================================================
# This script takes the embedded XML templates created by coral-tools and
# expands them into actual XML tool configuration files for SCRAM.
#
# Flow:
#   coral-tools creates .tmpl files (XML embedded in heredocs)
#       -> this script expands paths via envsubst
#       -> executes templates to produce final XML files
# =============================================================================

# Create the directory structure for tool configurations
# - selected/  : tools that are actively used in the build
# - available/ : tools that exist but are not currently selected
mkdir -p $INSTALLROOT/tools/{available,selected}

# Copy shared libraries from coral-tools installation
# These libs are needed by the tools at runtime
rsync -a $CORAL_TOOLS_ROOT/lib $INSTALLROOT/

# PKGINSTROOT is expanded by bash at template execution time — no envsubst needed
export PKGINSTROOT=$INSTALLROOT

# Execute templates directly; bash inherits PKGINSTROOT and expands it in the
# redirect targets (>> $PKGINSTROOT/tools/...) inside each heredoc
bash $CORAL_TOOLS_ROOT/tools/selected.tmpl
bash $CORAL_TOOLS_ROOT/tools/available.tmpl
