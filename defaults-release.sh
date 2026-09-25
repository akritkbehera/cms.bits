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
  cvmfs_releases_template: "{prefix}/{platform}/{family}{pkg}/{tag}"
  cvmfs_modules_template: "{prefix}/{platform}/modules/{pkg}"
  cvmfs_shared_path_template: "{prefix}/share/{family}{pkg}/{tag}"
---
