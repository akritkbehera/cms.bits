package: alpaka
version: 1.2.0
variables:
 git_commit: 1.2.0
sources:
 - https://github.com/cms-externals/%(package)s/archive/%(git_commit)s.tar.gz
requires:
 - boost
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cp -ar include $INSTALLROOT/include
