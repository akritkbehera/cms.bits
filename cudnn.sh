package: cudnn
version: "9.23.0.39"
requires:
- cuda
- gcc
- zlib
variables:
  cudaversion: "13"
  aarch64_src: "linux-sbsa"
  x86_64_src: "linux-x86_64"
  selected_src: "%%(%(platform_machine)s_src)s"
sources:
- https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/%(selected_src)s/cudnn-%(selected_src)s-%(version)s_cuda%(cudaversion)s-archive.tar.xz
---
if [ "${CUDA_VERSION%%.*.*}" != %(cudaversion)s ]; then
    echo 'Incompatible CUDA version in cudnn recipe!'
    exit 1
fi

tar -xJf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

# onnxruntime is hardcoded to look for the cudnn libraries under .../lib64
mv $BUILDDIR/lib $INSTALLROOT/lib64
mv $BUILDDIR/*   $INSTALLROOT/
