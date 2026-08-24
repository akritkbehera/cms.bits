package: cmssw-tool-conf
version: vCMS
variables:
 override_microarch_name: ""
requires:
 - cmssw-tools
hook: disable
---
#!include <tool-conf-flags.file>

mkdir -p $INSTALLROOT/tools/{available,selected}

rsync -a $CMSSW_TOOLS_ROOT/lib $INSTALLROOT/

export PKGINSTROOT=$INSTALLROOT

envsubst '$PKGINSTROOT' < $CMSSW_TOOLS_ROOT/tools/selected.tmpl > $INSTALLROOT/tools/template.tmpl

bash $INSTALLROOT/tools/template.tmpl

envsubst '$PKGINSTROOT' < $CMSSW_TOOLS_ROOT/tools/available.tmpl > $INSTALLROOT/tools/template.tmpl

bash $INSTALLROOT/tools/template.tmpl
