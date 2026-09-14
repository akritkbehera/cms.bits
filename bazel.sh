package: bazel
version: "7.7.0"
variables:
  aarch64_src: "linux-arm64"
  x86_64_src: "linux-x86_64"
  selected_src: "%%(%(platform_machine)s_src)s"
sources:
 - https://github.com/bazelbuild/bazel/releases/download/%(version)s/bazel-%(version)s-%(selected_src)s
build_requires:
 - java-env
requires:
 - gcc
---
# nothing to build: prebuilt upstream binary
mkdir -p "$INSTALLROOT/bin"
install -m 0755 "$SOURCEDIR/${SOURCE0}" "$INSTALLROOT/bin/bazel"
