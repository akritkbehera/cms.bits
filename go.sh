package: go
version: "1.22.5"
variables:
  aarch64_src: "arm64"
  x86_64_src: "amd64"
  selected_src: "%%(%(platform_machine)s_src)s"
sources:
 - https://go.dev/dl/go%(version)s.linux-%(selected_src)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

echo "hello"

rsync -a $BUILDDIR/ $INSTALLROOT/
