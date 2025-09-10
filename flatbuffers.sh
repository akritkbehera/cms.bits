package: flatbuffers
version: "2.0.6"
sources:
 - https://github.com/google/flatbuffers/archive/refs/tags/v%(version)s.tar.gz
 - https://patch-diff.githubusercontent.com/raw/google/flatbuffers/pull/7227.diff
patches: 
 - flatbuffers-7422.patch
build_requires:
 - CMake
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 -i $SOURCEDIR/$PATCH0
patch -p1 -i $SOURCEDIR/$SOURCE1

mkdir ../build
cd ../build

cmake $BUILDDIR -DCMAKE_BUILD_TYPE=$LLVM_BUILD_TYPE \
  -DFLATBUFFERS_BUILD_CPP17=ON \
  -DFLATBUFFERS_BUILD_SHAREDLIB=ON \
  -DFLATBUFFERS_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"

make -v ${JOBS+-j $JOBS} 
make ${JOBS+-j $JOBS} install
