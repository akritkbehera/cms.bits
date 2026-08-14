package: xtd
version: fdcc02011bbb1941f6b2c1226a9983a77d5a056e
variables:
  git_commit: "%(version)s"
sources:
  - https://github.com/cms-patatrack/xtd/archive/%(git_commit)s.tar.gz
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$INSTALLROOT"
cp -ar LICENSE   "$INSTALLROOT/LICENSE"
cp -ar README.md "$INSTALLROOT/README.md"
cp -ar include   "$INSTALLROOT/include"
