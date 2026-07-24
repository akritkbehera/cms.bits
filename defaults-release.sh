package: defaults-release
version: v1
variables:
  cms_cxx_std: 20
  cms_build_type: Release
env:
  CXXSTD: '20'
  DCMAKE_BUILD_TYPE: 'Release'
package_family:
  default: external
  lcg:
    - ROOT
    - SCRAMV1
  cms:
    - coral
    - data-[A-Z][-a-z0-9]*
    - cms-*
    - crab*
auto_patch: false
---
