package: defaults-cmssw
version: v1
variables:
  runGlimpse: yes
  saveDeps: yes
  subpackageDebug: yes
  gpu_backend_specific_packages: py-torch py-torch-sparse py-torch-cluster py-torch-scatter py-pyg-lib
  gpu_types: cuda rocm
  skipreqtools: jcompiler rivet2 opencl opencl-cpp intel-vtune icx-cxxcompiler icx-ccompiler icx-f77compiler mpich
  vectorized_packages: fastjet OpenBLAS rivet gbl lwtnn opencv tensorflow-sources tensorflow
---
