package: dip
version: fec745230594f2148b334cc467888aaf9447e124
sources:
  - http://cmsrep.cern.ch/cmssw/download/dip-v6.6.2.tar.gz
build_requires:
  - CMake
  - gmake
requires:
  - log4cplus
  - gcc
---
tar -xzf "$SOURCEDIR/$SOURCE0" -C "$BUILDDIR"
sed -i -e 's|log4cplus::log4cplus|log4cplus::log4cplusS|g' "$BUILDDIR/dip-v6.6.2/CMakeLists.txt"
sed -i -e '49s/if(NOT DIP_ACC)/if(NOT DIP_ACC AND WITH_JNI)/' -e '80s/if(NOT DIP_ACC)/if(NOT DIP_ACC AND WITH_JNI)/' "$BUILDDIR/dip-v6.6.2/CMakeLists.txt"
cmake -S "$BUILDDIR/dip-v6.6.2" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DCMAKE_BUILD_TYPE=Release \
  -DDIP_VERSION="6.6.2" \
  -DWITH_JNI=OFF \
  -DDIP_ACC=OFF \
  -DDIP_RPM=ON \
  -DCMAKE_PREFIX_PATH="$LOG4CPLUS_ROOT"
cmake --build "$BUILDDIR/build" ${JOBS:+--parallel $JOBS} -- VERBOSE=1
cmake --install "$BUILDDIR/build"

rm -rf "$INSTALLROOT/lib/cmake"
