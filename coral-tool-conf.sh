package: coral-tool-conf
version: vCMS
requires:
 - coral-tools
hook: disable
---
# =============================================================================
# coral-tool-conf: Deploys tool configuration files from coral-tools templates
# =============================================================================

# Create the directory structure for tool configurations
mkdir -p $INSTALLROOT/tools/{available,selected}

export PKGINSTROOT=$INSTALLROOT

export CMS_CXX_STANDARD="${CXXSTD:-20}"
bash $CORAL_TOOLS_ROOT/tools/selected.tmpl

# Create python3.xml as alias to python.xml (boost_python uses python3)
if [ -f "$INSTALLROOT/tools/selected/python.xml" ] && [ ! -f "$INSTALLROOT/tools/selected/python3.xml" ]; then
  sed 's/name="python"/name="python3"/' "$INSTALLROOT/tools/selected/python.xml" > "$INSTALLROOT/tools/selected/python3.xml"
fi
