package: opencl
version: "1.1"
---
mkdir -p "$INSTALLROOT"
ln -s /usr/lib64/nvidia   "$INSTALLROOT/lib64"
ln -s /usr/local/cuda/include "$INSTALLROOT/include"
