package: coral-tool-conf
version: vCMS
requires:
 - coral-tools
hook: disable
---
TOOL_CONF_SOURCE_ROOT="$CORAL_TOOLS_ROOT"
export CMS_CXX_STANDARD="${CXXSTD:-20}"
#!include <tool-conf-install.file>

# Create python3.xml as alias to python.xml (boost_python uses python3)
if [ -f "$INSTALLROOT/tools/selected/python.xml" ] && [ ! -f "$INSTALLROOT/tools/selected/python3.xml" ]; then
  sed 's/name="python"/name="python3"/' "$INSTALLROOT/tools/selected/python.xml" > "$INSTALLROOT/tools/selected/python3.xml"
fi
