package: tensorflow-sources
version: "2.21.0"
variables:
  tag: bc673ee0b966ac36ea73b9ab86d40967396a66a0
  branch: cms/v%(version)s
  github_user: cms-externals
  build_type: "opt"
  pythonOnly: "no"
  enable_gpu: "0"
sources:
 - git+https://github.com/%(github_user)s/tensorflow.git?obj=%(branch)s/%(tag)s&export=tensorflow-%(version)s&output=/tensorflow-%(version)s.tgz
patches:
 - tensorflow-tf2xla-return-type.patch
build_requires:
 - tensorflow-sources-cache
 - bazel
 - java-env
 - git
 # The wheel step shells out to `patchelf`. cmsdist gets it from the build OS; here it
 # only exists in this package.
 - patchelf-bootstrap
requires:
 - Python
 - py-numpy
 - py-pybind11
 - py-mock
 - py-typing-extensions
 - py-keras-applications
 - py-keras-preprocessing
 - py-future
 - py-wrapt
 - py-gast
 - setuptools
 - py-cython
 - py-protobuf
 - py-astor
 - py-six
 - py-termcolor
 - py-absl-py
 - py-flatbuffers
 - llvm
 - hwloc
 - py-psutil
 - py-lit
 - py-tblib
 - py-portpicker
 - eigen
 - protobuf
 - zlib
 - libpng
 - libjpeg-turbo
 - curl
 - giflib
 - sqlite
 - py-wheel
 - cuda
 - cudnn
 - grpc
 - abseil-cpp
 - flatbuffers
---
fetch_externals=no
#!include <tensorflow-build.file>
