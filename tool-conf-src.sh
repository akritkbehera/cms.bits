package: tool-conf-src
version: vCMS
variables:
  uctool: $(echo %{PACKAGE})

---
rm -rf $INSTALLROOT
mkdir -p $INSTALLROOT/tools/selected $INSTALLROOT/tools/available

%if "%{?skipreqtools:set}" != "set" 
%define skipreqtools %{nil}
%endif
