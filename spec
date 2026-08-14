%define __os_install_post %{nil}
%define __spec_install_post %{nil}
%define _empty_manifest_terminate_build 0
%define _use_internal_dependency_generator 0
%define _source_payload w9.gzdio
%define _binary_payload w9.gzdio
%define _rpmfilename %{NAME}.rpm

Name: %{rpm_name}
Version: %{version}
Release: %{revision}
Summary: %{summary}
License: CMS

%if 0%{?disable_autoreqprov}
AutoReqProv: no
%endif

%if 0%{?disable_autoreq}
AutoReq: no
%endif

%if %{?rpm_requires:1}%{!?rpm_requires:0}
%if "%{rpm_requires}" != "%{nil}"
Requires: %{rpm_requires}
%endif
%endif

%description
CMS package for %{pkgname}

%install
cp -a %{inst_root}/* %{buildroot}/

find %{buildroot} -type f -exec chmod u+w '{}' \;
find %{buildroot} -type d -exec chmod u+w '{}' \;

%files
/*

