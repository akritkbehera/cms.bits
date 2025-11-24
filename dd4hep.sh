package: dd4hep
version: v01-31-0x
variables:
  tag: 4990888b50e29a5dc0ff65fc3a6fdf17205192a5
  branch: master
  github_user: AIDASoft
build_requires:
 - CMake
 - gmake
requires:
 - clhep
 - expat
 - xerces-c
 - vecgeom
 - zlib
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
---
exit 1
