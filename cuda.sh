package: cuda
version: "13.4.2"
variables:
  driversversion: 615.71.09
  aarch64_src: "linux_sbsa"
  x86_64_src: "linux"
  selected_src: "%%(%(platform_machine)s_src)s"
  aarch64_driver: "linux-sbsa"
  x86_64_driver: "linux-x86_64"
  selected_driver: "%%(%(platform_machine)s_driver)s"
sources:
 - https://developer.download.nvidia.com/compute/cuda/%(version)s/local_installers/cuda_%(version)s_%(selected_src)s.run
 - https://developer.download.nvidia.com/compute/nvidia-driver/redist/nvidia_driver/%(selected_driver)s/nvidia_driver-%(selected_driver)s-%(driversversion)s-archive.tar.xz
requires:
 - Python
 - gcc
env:
  USE_CUDA: "1"
---
CUDADRIVER_VERSION="%(driversversion)s"
rm -rf "$BUILDDIR"/build "$BUILDDIR"/tmp
mkdir "$BUILDDIR"/build "$BUILDDIR"/tmp

# extract and repackage the CUDA runtime
cd "$BUILDDIR"/
# A pseudo-terminal prevents the runfile wrapper from trying to launch rxvt.
script -qec "/bin/sh '$SOURCEDIR/$SOURCE0' --silent --override --tmpdir='$BUILDDIR/tmp' --installpath='$BUILDDIR/build' --toolkit --keep" /dev/null

# create target directory structure
mkdir -p ${INSTALLROOT}/include
mkdir -p ${INSTALLROOT}/lib64

# package only the runtime static libraries
mv "$BUILDDIR"/build/lib64/libcudadevrt.a ${INSTALLROOT}/lib64/
mv "$BUILDDIR"/build/lib64/libcudart_static.a ${INSTALLROOT}/lib64/
rm -f "$BUILDDIR"/build/lib64/lib*.a

# the stub libraries will be replaced by the redistributable driver libraries
rm -rf "$BUILDDIR"/build/lib64/stubs/

# do not package the OpenCL libraries
rm -f "$BUILDDIR"/build/lib64/libOpenCL.*

# package the dynamic libraries
chmod a+x "$BUILDDIR"/build/lib64/*.so
mv "$BUILDDIR"/build/lib64/* ${INSTALLROOT}/lib64/

# package the includes
chmod a-x "$BUILDDIR"/build/include/*.h*
mv "$BUILDDIR"/build/include/* ${INSTALLROOT}/include/

# package the CUDA Profiling Tools Interface includes and libraries
chmod a+x "$BUILDDIR"/build/extras/CUPTI/lib64/*.so*
mv "$BUILDDIR"/build/extras/CUPTI/lib64/*.so* ${INSTALLROOT}/lib64/
mv "$BUILDDIR"/build/extras/CUPTI/include/*.h ${INSTALLROOT}/include/

# leave out the graphical tools, and package the other binaries
rm -f "$BUILDDIR"/build/bin/cuda-uninstaller
rm -f "$BUILDDIR"/build/bin/ncu*
rm -f "$BUILDDIR"/build/bin/nsight*
rm -f "$BUILDDIR"/build/bin/nsys*
mv "$BUILDDIR"/build/bin ${INSTALLROOT}/

# package the cuda-gdb support files, and set our PYTHONHOME
mv "$BUILDDIR"/build/share/ ${INSTALLROOT}/
sed -i '2a\
# Set PYTHONHOME\
export PYTHONHOME='$PYTHON_ROOT'\
' ${INSTALLROOT}/bin/cuda-gdb

# package the Compute Sanitizer, and replace the wrapper with a symlink
mv "$BUILDDIR"/build/compute-sanitizer ${INSTALLROOT}/
rm -f ${INSTALLROOT}/bin/compute-sanitizer
ln -s ../compute-sanitizer/compute-sanitizer ${INSTALLROOT}/bin/compute-sanitizer

# package the NVVM compiler (cicc), library (libnvvm.so), device library (libdevice.10.bc) and samples
mv "$BUILDDIR"/build/nvvm ${INSTALLROOT}/

# extract and repackage the redistributable NVIDIA driver libraries needed by the CUDA runtime
mkdir -p "$BUILDDIR"/nvidia-driver
tar xaf "$SOURCEDIR/$SOURCE1" --directory=${BUILDDIR}/nvidia-driver --strip-components=1

mkdir -p ${INSTALLROOT}/drivers
# libcuda.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libcuda.so.${CUDADRIVER_VERSION}                     ${INSTALLROOT}/drivers/
ln -sf libcuda.so.${CUDADRIVER_VERSION}                                                 ${INSTALLROOT}/drivers/libcuda.so.1
ln -sf libcuda.so.1                                                                 ${INSTALLROOT}/drivers/libcuda.so
# libcudadebugger.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libcudadebugger.so.${CUDADRIVER_VERSION}             ${INSTALLROOT}/drivers/
ln -sf libcudadebugger.so.${CUDADRIVER_VERSION}                                         ${INSTALLROOT}/drivers/libcudadebugger.so.1
ln -sf libcudadebugger.so.1                                                         ${INSTALLROOT}/drivers/libcudadebugger.so
# libnvidia-gpucomp.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-gpucomp.so.${CUDADRIVER_VERSION}           ${INSTALLROOT}/drivers/
ln -sf libnvidia-gpucomp.so.${CUDADRIVER_VERSION}                                       ${INSTALLROOT}/drivers/libnvidia-gpucomp.so
# libnvidia-nvvm.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-nvvm.so.${CUDADRIVER_VERSION}              ${INSTALLROOT}/drivers/
ln -sf libnvidia-nvvm.so.${CUDADRIVER_VERSION}                                          ${INSTALLROOT}/drivers/libnvidia-nvvm.so.4
ln -sf libnvidia-nvvm.so.4                                                          ${INSTALLROOT}/drivers/libnvidia-nvvm.so
# libnvidia-nvvm70.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-nvvm70.so.4                            ${INSTALLROOT}/drivers/
ln -sf libnvidia-nvvm70.so.4                                                        ${INSTALLROOT}/drivers/libnvidia-nvvm70.so
# libnvidia-pkcs11.so
if [ -f "$BUILDDIR"/nvidia-driver/lib/libnvidia-pkcs11.so.${CUDADRIVER_VERSION} ]; then
  cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-pkcs11.so.${CUDADRIVER_VERSION}          ${INSTALLROOT}/drivers/
  ln -sf libnvidia-pkcs11.so.${CUDADRIVER_VERSION}                                      ${INSTALLROOT}/drivers/libnvidia-pkcs11.so
fi
# libnvidia-pkcs11-openssl3.so
if [ -f "$BUILDDIR"/nvidia-driver/lib/libnvidia-pkcs11-openssl3.so.${CUDADRIVER_VERSION} ]; then
  cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-pkcs11-openssl3.so.${CUDADRIVER_VERSION} ${INSTALLROOT}/drivers/
  ln -sf libnvidia-pkcs11-openssl3.so.${CUDADRIVER_VERSION}                             ${INSTALLROOT}/drivers/libnvidia-pkcs11-openssl3.so
fi
# libnvidia-ptxjitcompiler.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-ptxjitcompiler.so.${CUDADRIVER_VERSION}    ${INSTALLROOT}/drivers/
ln -sf libnvidia-ptxjitcompiler.so.${CUDADRIVER_VERSION}                                ${INSTALLROOT}/drivers/libnvidia-ptxjitcompiler.so.1
ln -sf libnvidia-ptxjitcompiler.so.1                                                ${INSTALLROOT}/drivers/libnvidia-ptxjitcompiler.so
# libnvidia-tileiras.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-tileiras.so.${CUDADRIVER_VERSION}          ${INSTALLROOT}/drivers/
# nvidia-smi
cp -p "$BUILDDIR"/nvidia-driver/sbin/nvidia-smi                                      ${INSTALLROOT}/drivers/

# reuse the redistributable CUDA driver library and NVML library in place of the CUDA stub libraries
mkdir -p ${INSTALLROOT}/lib64/stubs
cp -p "$BUILDDIR"/nvidia-driver/lib/libcuda.so.${CUDADRIVER_VERSION}                     ${INSTALLROOT}/lib64/stubs/
ln -sf libcuda.so.${CUDADRIVER_VERSION}                                                 ${INSTALLROOT}/lib64/stubs/libcuda.so.1
ln -sf libcuda.so.1                                                                 ${INSTALLROOT}/lib64/stubs/libcuda.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libcudadebugger.so.${CUDADRIVER_VERSION}             ${INSTALLROOT}/lib64/stubs/
ln -sf libcudadebugger.so.${CUDADRIVER_VERSION}                                         ${INSTALLROOT}/lib64/stubs/libcudadebugger.so.1
ln -sf libcudadebugger.so.1                                                         ${INSTALLROOT}/lib64/stubs/libcudadebugger.so
cp -p "$BUILDDIR"/nvidia-driver/lib/libnvidia-ml.so.${CUDADRIVER_VERSION}                ${INSTALLROOT}/lib64/stubs/
ln -sf libnvidia-ml.so.${CUDADRIVER_VERSION}                                            ${INSTALLROOT}/lib64/stubs/libnvidia-ml.so.1
ln -sf libnvidia-ml.so.1                                                            ${INSTALLROOT}/lib64/stubs/libnvidia-ml.so

# Make nvcc use the package's own tools and libraries when invoked via a view.
# bits relocates INSTALLROOT references together with the rest of the package.
sed -i \
  -e "/^TOP *=/s|= .*|= $INSTALLROOT|" \
  -e 's|$(_HERE_)|$(TOP)/bin|g' \
  -e 's|/$(_TARGET_DIR_)||g' \
  -e 's|$(_TARGET_SIZE_)|64|g' "$INSTALLROOT/bin/nvcc.profile"
