package: git-lfs
version: "3.7.1"
variables:
  aarch64_src: "arm64"
  x86_64_src: "amd64"
  selected_src: "%%(%(platform_machine)s_src)s"
sources:
 - https://github.com/git-lfs/git-lfs/releases/download/v%(version)s/git-lfs-linux-%(selected_src)s-v%(version)s.tar.gz
requires:
 - git
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cd "$BUILDDIR"
PREFIX="$INSTALLROOT" ./install.sh
