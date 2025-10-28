package: cuda-compatible-runtime
version: vCMS
tag: 8069d15b0979cd4ec5c821960feb066a1e03f8ce
source: https://github.com/cms-patatrack/cuda-compatible-runtime.git
requires:
 - cuda
 - cuda-flags
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$BUILDDIR"/

$CUDA_ROOT/bin/nvcc ${nvcc_flags_stdcxx} -O2 -g $nvcc_flags_cuda_archs test.cu -I $CUDA_ROOT/include -L $CUDA_ROOT/lib64 -L $CUDA_ROOT/lib64/stubs --cudart static -ldl -lrt --compiler-options '-Wall -pthread' -o $BUILDDIR/build/cuda-compatible-runtime

exit 1
