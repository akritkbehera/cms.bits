package: defaults-cms
version: v1
variables:
  gcc: 'true'
  vecgeom: 'true'
env:
  CMS_CXX_STD: '20'
  EXTERNALS_BUILD_TYPE: 'Release'
  LTO_BUILD_FLAGS: '-flto=auto -fipa-icf -flto-odr-type-merging -fno-fat-lto-objects -Wodr'
auto_patch: false
revision_policy: hash
package_family:
  default: external
  lcg:
    - ROOT
    - SCRAMV1
  cms:
    - coral*
    - data-[A-Z][-a-z0-9]*
    - cms*
    - cmssw*
    - crab*
---
