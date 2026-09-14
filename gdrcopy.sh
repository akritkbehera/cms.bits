package: gdrcopy
version: "v2.6"
sources:
  - https://github.com/NVIDIA/gdrcopy/archive/%(version)s.tar.gz
build_requires:
 - gmake
requires:
 - cuda
 - gcc
prepend_path:
  LD_LIBRARY_PATH: $GDRCOPY_ROOT/lib64
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
make ${JOBS:+-j$JOBS} prefix=$INSTALLROOT libdir=$INSTALLROOT/lib64 CUDA=$CUDA_ROOT lib
make ${JOBS:+-j$JOBS} prefix=$INSTALLROOT libdir=$INSTALLROOT/lib64 CUDA=$CUDA_ROOT lib_install