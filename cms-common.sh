package: cms-common
version: "1.0"
variables:
  tag: ac5bdc65fd10fdcc5b52cf855b7c67c92bf8627e
sources:
 - git+https://github.com/cms-sw/cms-common.git?obj=master/%(tag)s&export=%(package)s-%=(version)s-%(tag)s&output=/%(package)s-%(version)s-%(tag)s.tgz
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

