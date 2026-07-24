package: log4cplus
version: 2.0.7
sources:
 - https://github.com/%(package)s/%(package)s/releases/download/REL_2_0_7/%(package)s-%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR" 

cmake -S "$BUILDDIR" -B "$BUILDDIR/build" \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
  -DBUILD_SHARED_LIBS:BOOL=OFF \
  -DLOG4CPLUS_BUILD_TESTING=OFF \
  -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install
