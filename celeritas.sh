package: celeritas
version: 0.6.0
tag: dfa4cde7d7d65bf656b17a24c59fcc030aa6b0d9
source: https://github.com/celeritas-project/celeritas
variables:
 package_build_flags: "-Wall -Wextra -pedantic"
build_requires:
 - gmake
 - CMake
requires:
 - gcc
 - Python
 - json
 - geant4
 - clhep
 - expat
 - xerces-c
 - zlib
 - compilation_flags
 - compilation_flags_lto
---
