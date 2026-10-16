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
    - data-*
    - cms*
    - crab*
    - cmssw*
    - CMSSW*
auto_patch: false
hook:
  POST_INSTALL: check_dependencies,generate_module
revision_policy: "hash"
system:
  prefix: "/cvmfs"
  install_dir: "/home/akbehera/Desktop/x86-64/sw/el9_amd64_gcc14"
  module_dir: "/home/akbehera/Desktop/x86-64/sw/MODULES/el9_amd64_gcc14"
---
