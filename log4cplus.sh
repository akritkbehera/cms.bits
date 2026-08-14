package: log4cplus
version: 2.1.2
sources:
 - https://github.com/log4cplus/log4cplus/releases/download/REL_2_1_2/log4cplus-2.1.2.tar.gz
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
  -DWITH_UNIT_TESTS=OFF \
  -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF

make -C "$BUILDDIR/build" ${JOBS:+-j$JOBS} VERBOSE=1
make -C "$BUILDDIR/build" install
