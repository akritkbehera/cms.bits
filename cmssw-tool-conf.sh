package: cmssw-tool-conf
version: vCMS
requires:
 - cmssw-tools
---
mkdir -p $INSTALLROOT/tools/{available,selected}

rsync -a $CMSSW_TOOLS_ROOT/lib $INSTALLROOT/

export PKGINSTROOT=$INSTALLROOT

envsubst '$PKGINSTROOT' < $CMSSW_TOOLS_ROOT/tools/selected.tmpl > $INSTALLROOT/tools/template.tmpl

bash $INSTALLROOT/tools/template.tmpl

envsubst '$PKGINSTROOT' < $CMSSW_TOOLS_ROOT/tools/available.tmpl > $INSTALLROOT/tools/template.tmpl

bash $INSTALLROOT/tools/template.tmpl
