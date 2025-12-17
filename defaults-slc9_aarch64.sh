package: defaults-slc9_aarch64
version: vCMS
env:
  CMS_EIGEN_CXX_FLAGS: -DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64
  arch_build_flags: '-march=armv8-a -mno-outline-atomics'
  lto_build_flags: '-flto=auto -fipa-icf -flto-odr-type-merging -fno-fat-lto-objects -Wodr '
---
