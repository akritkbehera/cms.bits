package: torch
version: 2.6.0
tag: v%(version)s
source: https://github.com/pytorch/pytorch.git
patches:
 - pytorch-missing-braces.patch
 - pytorch-system-fmt.patch
 - FindEigen3.cmake.file
requires:
 - cuda-flags
 - microarch-flag
 - CMake
 - ninja
 - eigen
 - fxdiv
 - numactl
 - openmpi
 - protobuf
 - psimd
 - Python
 - py-PyYAML
 - OpenBLAS
 - zlib
 - fmt
 - py-pybind11
 - py-typing-extensions
 - cuda
 - cudnn
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/

