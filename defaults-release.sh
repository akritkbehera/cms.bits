package: defaults-release
version: vCMS
variables:
  cms_cxx_std: "20"
  cms_build_type: "Release"
  override_microarch_name: ""
env:
  CXXSTD: '20'
  DCMAKE_BUILD_TYPE: 'Release'
package_family:
  default: external
  lcg:
    - ROOT
    - SCRAMV1
  cms:
    - coral*
    - data-[A-Z][-a-z0-9]*
    - cms*
    - crab*
    - cmssw*
    - CMSSW*
auto_patch: false
hook:
  POST_INSTALL: check_dependencies
---
