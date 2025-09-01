package: tensorflow
version: "2.12.0"
sources:
 - https://github.com/tensorflow/tensorflow/archive/refs/tags/v%(version)s.tar.gz
patches:
 - tensorflow-gcc14-aarch64.patch
requires:
 - gcc
 - Python
 - py-numpy
 - py-mock
 - py-typing-extensions
 - py-keras-applications
 - py-keras-preprocessing
 - py-future
 - py-wrapt
 - py-gast
 - setuptools
 - py-opt-einsum
 - py-flatbuffers
 - eigen
 - protobuf
 - zlib
 - libpng
 - libjpeg-turbo
 - curl
 - giflib
 - sqlite
 - py-pybind11
 - py-wheel
 - cuda
 - cudnn
 - grpc
 - flatbuffers
---
export ENABLE_TK_MKLDNN=1
export TF_CXXSTD=17
export build_type=opt
export pythonOnly=no
export USE_DEFAULT_PYTHON_LIB_PATH=1
export GCC_HOST_COMPILER_PATH="$(which gcc)"
export CC_OPT_FLAGS="-Wno-sign-compare"
