package: tensorflow
version: "2.12.0"
variables:
  tag: 4a22f3b460370aa5b1c60579104cd103e8f0d6bb
  branch: cms/v%%(version)s
  github_user: cms-externals
  build_type: "opt"
  pythonOnly: "no"
  enable_gpu: "0"
sources:
 - git+https://github.com/%(github_user)s/tensorflow.git?obj=%(branch)s/%(tag)s&export=tensorflow-%(version)s&output=/tensorflow-%(version)s.tgz
patches:
 - tensorflow-gcc14-aarch64.patch
build_requires:
 - bazel
 - java-env
 - git
requires:
 - Python
 - compilation_flags
 - microarch-flag
 - py-numpy
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
export CXXSTD=17
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"


sed -i -e "s|lib/python[^/]*/site-packages/|lib/python3.9/site-packages/|" third_party/systemlibs/pybind11.BUILD

export pythonOnly="${pythonOnly:-no}"
export build_type="${build_type:-opt}"
export MAJOR_VERSION=$(echo "$PKG_VERSION" | cut -d. -f1)
export PYTHON_BIN_PATH="$(which python3)"
export USE_DEFAULT_PYTHON_LIB_PATH=1
export GCC_HOST_COMPILER_PATH="$(which gcc)"
export CC_OPT_FLAGS="-Wno-sign-compare"
export BAZEL_OPTS="--batch --output_user_root ../build"

if [ $(${JAVA_HOME}/bin/java -version 2>&1 | grep -E -i 'openjdk version "[1-9]' | sed -E 's|.* "([0-9]+)[.].*|\1|') -ge 17 ] ; then
BAZEL_OPTS="$BAZEL_OPTS --host_jvm_args=--add-opens=java.base/java.nio=ALL-UNNAMED"
BAZEL_OPTS="$BAZEL_OPTS --host_jvm_args=--add-opens=java.base/java.lang=ALL-UNNAMED"
fi

BAZEL_OPTS="$BAZEL_OPTS build -s --verbose_failures --distinct_host_configuration=false"

if [[ -n "$selected_microarch" ]]; then
  BAZEL_OPTS="$BAZEL_OPTS --copt=$selected_microarch"

  if [[ "$selected_microarch" != "$default_microarch" ]]; then
    BAZEL_OPTS="$BAZEL_OPTS --distinct_host_configuration=true"
  fi
fi

if [[ -n "$arch_build_flags" ]]; then
  BAZEL_OPTS+=" $(for f in $arch_build_flags; do echo --copt=$f; done)"
fi

BAZEL_OPTS+=" --config=$build_type \
  --cxxopt=-std=c++$CXXSTD \
  --host_cxxopt=-std=c++$CXXSTD \
  --jobs=${JOBS:-$(nproc)}"

BAZEL_OPTS+=" --config=noaws --config=nogcp --config=nohdfs --config=nonccl"

if [[ "$enable_tf_mkldnn" == "0" ]]; then
  BAZEL_OPTS+=" --define=zendnn=true \
    --define=build_with_mkl_dnn_only=false \
    --define=build_with_mkl=false \
    --define=enable_mkl=false \
    --define=tensorflow_mkldnn_contraction_kernel=0 \
    --define=build_with_mkl_opensource=false"
fi

if [[ "$(uname -m)" == "ppc64le" ]]; then
  BAZEL_OPTS+=" --define=tflite_with_xnnpack=false \
    --define=tflite_kernel_use_xnnpack=false"
fi

if [[ "%(enable_gpu)s" == "1" ]]; then
  BAZEL_OPTS+=" --config=cuda"

  export GCC_HOST_COMPILER_PREFIX="${GCC_ROOT}/bin"
  export GCC_HOST_COMPILER_PATH="$(which gcc)"
  export TF_CUDA_COMPUTE_CAPABILITIES="$(echo "compute_${cuda_arch}" | sed 's|\s\s*|,compute_|g')"
  export TF_CUDA_VERSION="$(echo "$CUDA_VERSION" | cut -f1,2 -d.)"
  export TF_CUDA_PATHS="${CUDA_ROOT},${CUDNN_ROOT}"
  export TF_CUDA_CLANG=0
  export cuda=Y
fi

export TF_NEED_CUDA="%(enable_gpu)s"
export TF_NEED_JEMALLOC=0
export TF_NEED_HDFS=0
export TF_NEED_GCP=0
export TF_ENABLE_XLA=1
export TF_NEED_OPENCL=0
export TF_NEED_VERBS=0
export TF_NEED_MKL=0
export TF_NEED_MPI=0
export TF_NEED_S3=0
export TF_NEED_GDR=0
export TF_NEED_OPENCL_SYCL=0
export TF_SET_ANDROID_WORKSPACE=false
export TF_NEED_KAFKA=false
export TF_NEED_AWS=0
export TF_DOWNLOAD_CLANG=0
export TF_NEED_IGNITE=0
export TF_NEED_ROCM=0
export TF_NEED_TENSORRT=0
export TEST_TMPDIR=$BUILDDIR/build
export TF_CMS_EXTERNALS="$BUILDDIR/cms_externals.txt"


echo "png:${LIBPNG_ROOT}"                   >> ${TF_CMS_EXTERNALS}
echo "libjpeg_turbo:${LIBJPEG_TURBO_ROOT}"  >> ${TF_CMS_EXTERNALS}
echo "zlib:${ZLIB_ROOT}"                    >> ${TF_CMS_EXTERNALS}
echo "eigen_archive:${EIGEN_ROOT}"          >> ${TF_CMS_EXTERNALS}
echo "curl:${CURL_ROOT}"                    >> ${TF_CMS_EXTERNALS}
echo "com_google_protobuf:${PROTOBUF_ROOT}" >> ${TF_CMS_EXTERNALS}
echo "com_github_grpc_grpc:${GRPC_ROOT}"    >> ${TF_CMS_EXTERNALS}
echo "gif:${GIFLIB_ROOT}"                   >> ${TF_CMS_EXTERNALS}
echo "org_sqlite:${SQLITE_ROOT}"            >> ${TF_CMS_EXTERNALS}
echo "cython:"                              >> ${TF_CMS_EXTERNALS}
echo "flatbuffers:${FLATBUFFERS_ROOT}"      >> ${TF_CMS_EXTERNALS}
echo "pybind11:${PY_PYBIND11_ROOT}"         >> ${TF_CMS_EXTERNALS}
echo "functools32_archive:"                 >> ${TF_CMS_EXTERNALS}
echo "astor_archive:"                       >> ${TF_CMS_EXTERNALS}
echo "six_archive:"                         >> ${TF_CMS_EXTERNALS}
echo "absl_py:${PY_ABSL_PY_ROOT}"           >> ${TF_CMS_EXTERNALS}
echo "termcolor_archive:"                   >> ${TF_CMS_EXTERNALS}
echo "typing_extensions_archive:"           >> ${TF_CMS_EXTERNALS}
echo "pasta:"                               >> ${TF_CMS_EXTERNALS}
echo "wrapt:"                               >> ${TF_CMS_EXTERNALS}
echo "gast_archive:"                        >> ${TF_CMS_EXTERNALS}
echo "org_python_pypi_backports_weakref:"   >> ${TF_CMS_EXTERNALS}
echo "opt_einsum_archive:"                  >> ${TF_CMS_EXTERNALS}
echo "boringssl:"                           >> ${TF_CMS_EXTERNALS}

export TF_SYSTEM_LIBS=$(cat ${TF_CMS_EXTERNALS} | sed 's|:.*||' | tr "\n" "," | sed 's|,*$||')

if [ -d ../build ] ; then
  chmod -R u+w  ../build
  rm -rf ../build
fi

./configure
rm -rf "$BUILDDIR/cms-pytool"
mkdir -p "$BUILDDIR/cms-pytool"
echo '#!/bin/bash'                            >  "$BUILDDIR/cms-pytool/python3"
echo "export PYTHON3PATH=\"${PYTHON3PATH}\"" >> "$BUILDDIR/cms-pytool/python3"
echo "$(which python3) \"\$@\""              >> "$BUILDDIR/cms-pytool/python3"
chmod +x "$BUILDDIR/cms-pytool/python3"
ln -s python3 "$BUILDDIR/cms-pytool/python"
export PATH="$BUILDDIR/cms-pytool:$PATH"

# Always build the pip package
bazel $BAZEL_OPTS //tensorflow/tools/pip_package:build_pip_package

if [[ "%(pythonOnly)s" == "no" ]]; then
  bazel $BAZEL_OPTS //tensorflow:tensorflow
  bazel $BAZEL_OPTS //tensorflow:tensorflow_cc
  bazel $BAZEL_OPTS //tensorflow/tools/graph_transforms:transform_graph
  bazel $BAZEL_OPTS //tensorflow/compiler/tf2xla:tf2xla
  bazel $BAZEL_OPTS //tensorflow/compiler/xla:cpu_function_runtime
  bazel $BAZEL_OPTS //tensorflow/compiler/xla:executable_run_options
  bazel $BAZEL_OPTS //tensorflow/compiler/tf2xla:xla_compiled_cpu_function
  # bazel $BAZEL_OPTS //tensorflow/compiler/aot:tfcompile   # left commented
  bazel $BAZEL_OPTS //tensorflow/core/profiler
  bazel $BAZEL_OPTS //tensorflow:install_headers
  bazel $BAZEL_OPTS //tensorflow/compiler/tf2xla:tf2xla_supported_ops
fi

chmod -R a+rwX "$PWD/bazel-bin/tensorflow/include"
for f in $(find tensorflow -name "*.proto"); do
  protoc --cpp_out="$PWD/bazel-bin/tensorflow/include" "$f"
done

# Only install native libs if not Python-only
if [[ "$pythonOnly" == "no" ]]; then
  # Define and create empty target directories
  outdir="$PWD/out"
  bindir="$outdir/bin"
  incdir="$outdir/include"
  libdir="$outdir/lib"

  rm -rf "$bindir" "$incdir" "$libdir"
  mkdir -p "$bindir" "$incdir" "$libdir"

  # Copy Bazel-built artifacts
  srcdir="$PWD/bazel-bin/tensorflow"

  cp -p "$srcdir"/libtensorflow*.so* "$libdir"/
  cp -p "$srcdir"/compiler/tf2xla/lib*.so* "$libdir"/
  cp -p "$srcdir"/compiler/xla/lib*.so* "$libdir"/

  # Create proper SONAME symlinks
  for l in tensorflow_cc tensorflow_framework tensorflow; do
    # check if the actual lib exists
    if [[ ! -f "$libdir/lib${l}.so.$PKG_VERSION" ]]; then
      echo "Missing library: $libdir/lib${l}.so.$PKG_VERSION"
      exit 1
    fi

    rm -f "$libdir/lib${l}.so.$MAJOR_VERSION"
    ln -s "lib${l}.so.$PKG_VERSION" "$libdir/lib${l}.so.$MAJOR_VERSION"

    rm -f "$libdir/lib${l}.so"
    ln -s "lib${l}.so.$MAJOR_VERSION" "$libdir/lib${l}.so"
  done

  # Copy additional binaries and includes
  cp -p "$srcdir"/compiler/tf2xla/tf2xla_supported_ops "$bindir"
  for name in tensorflow absl re2 third_party; do
    cp -r -p "$srcdir/include/$name" "$incdir"
  done

  # Copy headers from downloaded dependencies
  copy_headers() {
    for header_file in $(find "$1/$2" -name '*.h' | sed "s|$1/||"); do
      header_dir="${incdir}/$(dirname "${header_file}")"
      mkdir -p "${header_dir}"
      cp -p "${header_file}" "${header_dir}/"
    done
  }
  copy_headers "$PWD" tensorflow/compiler
  copy_headers "$PWD" tensorflow/core/profiler/internal
  copy_headers "$PWD" tensorflow/core/profiler/lib
  copy_headers "$PWD" tensorflow/core/util/tensor_bundle

  # Package the output into a tarball
  pushd "$outdir" > /dev/null
    tar cfz "$INSTALLROOT/libtensorflow_cc.tar.gz" .
  popd > /dev/null
fi

optdir=$(ls -d $PWD/bazel-out/*-"$build_type")

if [ -L ${optdir}/bin/external/farmhash_gpu_archive/_virtual_includes/farmhash_gpu/third_party/farmhash_gpu/src/farmhash_gpu.h ] ; then
  if [ ! -e ${optdir}/bin/external/farmhash_gpu_archive/_virtual_includes/farmhash_gpu/third_party/farmhash_gpu/src/farmhash_gpu.h ] ; then
    ln -sf ${optdir}/bin/tensorflow/tools/pip_package/build_pip_package.runfiles/org_tensorflow/external/farmhash_gpu_archive/src/farmhash_gpu.h \
           ${optdir}/bin/external/farmhash_gpu_archive/_virtual_includes/farmhash_gpu/third_party/farmhash_gpu/src/farmhash_gpu.h
  fi
fi

# create the wheel file that is installed in py2-tensorflow
bazel-bin/tensorflow/tools/pip_package/build_pip_package $INSTALLROOT
