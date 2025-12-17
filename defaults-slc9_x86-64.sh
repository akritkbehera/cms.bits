package: defaults-slc9_x86-64
version: vCMS
env:
 CMS_EIGEN_CXX_FLAGS: -DEIGEN_DONT_PARALLELIZE -DEIGEN_MAX_ALIGN_BYTES=64
 arch_build_flags: ''
 lto_build_flags: '-flto=auto -fipa-icf -flto-odr-type-merging -fno-fat-lto-objects -Wodr '
 default_microarch: "-march=x86-64-v3"
 arch: "$(/usr/lib64/ld-linux-x86-64.so.2 --help | grep 'x86-64-v*' | grep 'supported' | head -n 1 | awk '{print $1}')"
 selected_microarch: "-march=${override_microarch:-$arch}"
---
