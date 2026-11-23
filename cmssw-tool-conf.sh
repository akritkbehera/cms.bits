package: cmssw-tool-conf
version: vCMS
variables:
 override_microarch_name: ""
requires:
 - cmssw-tools
hook: disable
---
#!include <tool-conf-flags.file>
TOOL_CONF_SOURCE_ROOT="$CMSSW_TOOLS_ROOT"
#!include <tool-conf-install.file>


