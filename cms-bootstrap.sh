package: cms-bootstrap
version: "1.0"
force_revision: ""
requires:
 - SCRAMV1
 - SCRAMV2
 - cmssw-wm-tools
 - cms-git-tools
 - crab
sources:
 - file://hooks/check_dependencies.py
hook: disable
---
mkdir -p "$INSTALLROOT/bin"
install -m 755 "$SOURCEDIR/$SOURCE0" "$INSTALLROOT/bin/check_dependencies.py"
