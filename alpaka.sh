package: alpaka
version: 2.2.0
sources:
 - https://github.com/alpaka-group/%(package)s/archive/%(version)s.tar.gz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

cp -ar include $INSTALLROOT/include
