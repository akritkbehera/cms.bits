package: re2
version: "2021-06-01"
sources: 
 - https://github.com/google/re2/archive/%(version)s.tar.gz
build_requires:
 - CMake
 - gmake
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cmake \
  -DCMAKE_INSTALL_PREFIX:PATH=$INSTALLROOT \
  -DCMAKE_BUILD_TYPE=$LLMV_BUILD_TYPE \
  -DBUILD_SHARED_LIBS=True \
  -DCMAKE_POSITION_INDEPENDENT_CODE=True \
  -DCMAKE_INSTALL_LIBDIR=lib

make VERBOSE=1 ${JOBS:+-j$JOBS} install
