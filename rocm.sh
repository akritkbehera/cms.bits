package: rocm
version: "7.14"
# Meta-package: upstream split monolithic ROCm into these components (port of rocm.spec).
requires:
  - rocm-llvm
  - rocr-runtime
  - rocm-hip
  - rocm-core
  - rocm-cmake
  - rocminfo
  - rocdbgapi
  - rocgdb
  - rocprofiler
  - rocprofiler-register
  - rocprofiler-compute
  - rocm-rocprofiler-sdk
  - rocm-rocprofiler-systems
  - roctracer
  - aqlprofile
  - rocm-smi-lib
  - amdsmi
  - rccl
  - rocshmem
  - hipblas-common
  - hipblas
  - rocblas
  - hipblaslt
  - hipsolver
  - rocsolver
  - hipsparse
  - rocsparse
  - hipsparselt
  - hipfft
  - rocfft
  - hiprand
  - hipcub
  - rocprim
  - rocthrust
  - miopen
  - rocrand
  - rocm-comgr
---
mkdir -p "$INSTALLROOT"
