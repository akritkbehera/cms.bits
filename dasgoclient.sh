package: dasgoclient
version: vCMS
variables:
  version_suffix: 00
  dasgoclient_tag: v02.04.52
sources:
 - https://github.com/dmwm/dasgoclient/releases/download/%(dasgoclient_tag)s/dasgoclient_%(platform_machine)s
---
mkdir $INSTALLROOT/etc $INSTALLROOT/bin
cat << EOF > $INSTALLROOT/etc/dasgoclient
#!bin/sh
#CMSDIST_FILE_REVISION=1
# Clean-up CMSSW environment
if [ -f $WORK_DIR/common
