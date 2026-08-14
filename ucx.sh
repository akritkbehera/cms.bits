package: ucx
version: "1.21.0"
sources:
  # submodules=1 is required: ucx 1.21 pulls the DOCA gpunetio headers
  # (external/gpunetio -> NVIDIA-DOCA/gpunetio) needed by the mlx5 gda component.
  - git+https://github.com/openucx/ucx.git?obj=master/v%(version)s&export=ucx-%(version)s&submodules=1&output=/ucx.tar.gz
build_requires:
 - autotools
requires:
 - gcc
 - numactl
 - rdma-core
 - xpmem
 - cuda
 - rocm-hip
 - rocr-runtime
 - gdrcopy
---
#!include <microarch-flags.file>
#!include <cuda-flags.file>

tar -xzf "$SOURCEDIR/${SOURCE0}" --strip-components=1 -C "$BUILDDIR"

./autogen.sh

CONFIGURE_OPTS="\
  --prefix=$INSTALLROOT \
  --disable-dependency-tracking \
  --enable-openmp \
  --enable-shared \
  --disable-static \
  --enable-ucg \
  --disable-doxygen-doc \
  --disable-doxygen-man \
  --disable-doxygen-html \
  --enable-compiler-opt \
  --enable-cma \
  --enable-mt \
  --disable-logging \
  --disable-debug \
  --disable-assertions \
  --disable-params-check \
  --with-pic \
  --with-gnu-ld \
  --without-go \
  --without-java"

# Conditionally enable CUDA (microarch now via CFLAGS below; x86-64-v2 block dropped upstream)
if [ -z "$without_cuda" ]; then
  CONFIGURE_OPTS+=" --with-cuda=$CUDA_ROOT"
  CONFIGURE_OPTS+=" --with-gdrcopy=$GDRCOPY_ROOT"
  # --with-nvcc-gencode is a single value containing spaces (-gencode ... -Wno-...);
  # pass it as one quoted arg at the configure call (see below), not via the
  # word-split CONFIGURE_OPTS string.
else
  CONFIGURE_OPTS+=" --without-cuda"
  CONFIGURE_OPTS+=" --without-gdrcopy"
fi

# Conditionally enable ROCM (rocm split into rocm-hip / rocr-runtime upstream)
if [ -z "$without_rocm" ]; then
  CONFIGURE_OPTS+=" --with-rocm=$ROCM_HIP_ROOT"
else
  CONFIGURE_OPTS+=" --without-rocm"
fi

CONFIGURE_OPTS+=" \
  --with-verbs=$RDMA_CORE_ROOT \
  --with-rc \
  --with-ud \
  --with-dc \
  --with-mlx5-dv \
  --with-ib-hw-tm \
  --with-dm \
  --with-rdmacm=$RDMA_CORE_ROOT \
  --without-knem \
  --with-xpmem=$XPMEM_ROOT \
  --without-ugni"

export CPPFLAGS="-I$NUMACTL_ROOT/include"
export LDFLAGS="-L$NUMACTL_ROOT/lib"
export CFLAGS="$selected_microarch"

if [ -z "$without_cuda" ]; then
  ./configure $CONFIGURE_OPTS --with-nvcc-gencode="$nvcc_flags_cuda_archs"
else
  ./configure $CONFIGURE_OPTS
fi
make ${JOBS:+-j$JOBS}
make install

rm -rf $INSTALLROOT/lib/pkgconfig
rm -f $INSTALLROOT/lib/lib*.la
rm -f $INSTALLROOT/lib/ucx/lib*.la
rm -rf $INSTALLROOT/share/ucx/examples
