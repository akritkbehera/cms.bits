package: gdrcopy
version: "%(tag_basename)s"
tag: v2.6
source: https://github.com/NVIDIA/gdrcopy
build_requires:
 - gmake
requires:
 - cuda
 - gcc
prepend_path:
  LD_LIBRARY_PATH: $GDRCOPY_ROOT/lib64
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/
make ${JOBS:+-j$JOBS} prefix=$INSTALLROOT libdir=$INSTALLROOT/lib64 CUDA=$CUDA_ROOT lib
make ${JOBS:+-j$JOBS} prefix=$INSTALLROOT libdir=$INSTALLROOT/lib64 CUDA=$CUDA_ROOT lib_install