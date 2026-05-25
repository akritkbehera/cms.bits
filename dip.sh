package: dip
version: 8693f00cc422b4a15858fcd84249acaeb07b6316
variables:
  xtag: f41e221f8fb95830fc001dad975b4db770f5d29d
sources:
  - git+https://:@gitlab.cern.ch:8443/industrial-controls/services/dip-hq/dip.git?obj=develop/%(version)s&export=%(package)s&output=/%(package)s-%(version)s.tgz
  - git+https://:@gitlab.cern.ch:8443/industrial-controls/services/dip-hq/platform-dependent.git?obj=develop/%(xtag)s&export=platform-dependent&output=/platform-dependent-%(xtag)s.tgz
build_requires:
  - CMake
  - gmake
requires:
  - log4cplus
  - gcc
---
tar -xzf "$SOURCEDIR/$SOURCE0" -C "$BUILDDIR"
tar -xzf "$SOURCEDIR/$SOURCE1" -C "$BUILDDIR"

# Patch out conan dependencies
sed -i -e '/conanbuildinfo.cmake\|conan_basic_setup/d' "$BUILDDIR/dip/CMakeLists.txt"
sed -i -e 's|CONAN_PKG::||g;s|log4cplus|log4cplusS|' "$BUILDDIR/dip/CMakeLists.txt"
sed -i -e '/conanbuildinfo.cmake\|conan_basic_setup/d' "$BUILDDIR/platform-dependent/CMakeLists.txt"

# Build platform-dependent first
mkdir -p "$BUILDDIR/build/platform-dependent"
cd "$BUILDDIR/build/platform-dependent"
cmake "$BUILDDIR/platform-dependent" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
make ${JOBS:+-j$JOBS} VERBOSE=1
make install

# Build dip
mkdir -p "$BUILDDIR/build/dip"
cd "$BUILDDIR/build/dip"
LDFLAGS="-L${LOG4CPLUS_ROOT}/lib64 -L$INSTALLROOT/lib" \
  CXXFLAGS="-I$INSTALLROOT/include -I${LOG4CPLUS_ROOT}/include" \
  cmake "$BUILDDIR/dip" -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"
make ${JOBS:+-j$JOBS} VERBOSE=1
make install
rm -rf "$INSTALLROOT/lib/cmake"
