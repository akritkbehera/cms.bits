package: xtd
version: fdcc02011bbb1941f6b2c1226a9983a77d5a056e
sources:
  - https://github.com/cms-patatrack/%(package)s/archive/%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p "$INSTALLROOT"
cp -ar LICENSE   "$INSTALLROOT/LICENSE"
cp -ar README.md "$INSTALLROOT/README.md"
cp -ar include   "$INSTALLROOT/include"
