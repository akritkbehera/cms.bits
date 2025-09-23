package: tensorflow
version: 2.12.0
requires:
 - tensorflow-sources
---
tar xfz "$TENSORFLOW_SOURCES_ROOT/libtensorflow_cc.tar.gz" -C "$INSTALLROOT"

if [[ "%(enable_gpu)s" == "1" ]]; then
  mkdir -p "$INSTALLROOT/etc/scram.d"
  cat <<'EOF_TOOLFILE' >"$INSTALLROOT/etc/scram.d/tf_cuda_support.xml"
  <tool name="tf_cuda_support" version="1.0" revision="1">
  </tool>
EOF_TOOLFILE
fi
