package: tfaot-model-test-multi
version: 1.0.1
build_requires:
  - py-cms-tfaot
requires:
  - gcc
  - tensorflow-xla-runtime
  - py-tensorflow
---
# aot config for the model to compile, shipped by py-cms-tfaot
aot_config="$PY_CMS_TFAOT_ROOT/share/test_models/multi/aot_config.yaml"

if [ "$(uname -m)" = "ppc64le" ]; then
  build_arch="powerpc64le-unknown-linux-gnu"
else
  build_arch="$(uname -m)-unknown-linux-gnu"
fi

cms_tfaot_compile \
  --aot-config "$aot_config" \
  --tool-name "$PKGNAME" \
  --tool-base "$INSTALLROOT" \
  --output-directory compiled_model \
  --additional-flags="--target_triple $build_arch"

mkdir -p "$INSTALLROOT/lib"
mv compiled_model/*.o "$INSTALLROOT/lib/"

mkdir -p "$INSTALLROOT/include/$PKGNAME"
mv compiled_model/*.h "$INSTALLROOT/include/$PKGNAME"

mkdir -p "$INSTALLROOT/etc/scram.d"
mv "compiled_model/$PKGNAME.xml" "$INSTALLROOT/etc/scram.d/"
