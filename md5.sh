package: md5
version: 2.0.0
variables:
  tag: 1ed14d187d793216fb8345363f590bf3effd95e2
  branch: cms/%(version)s
  github_user: cms-externals
sources:
 - git+https://github.com/%(github_user)s/%(package)s.git?obj=%(branch)s/%(tag)s&export=%(package)s-%(version)s&output=/%(package)s-%(version)s-%(tag)s.tgz
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

c++ edm_md5.c -shared -fPIC -o libcms-md5.so

mkdir -p $INSTALLROOT/lib $INSTALLROOT/include
cp $BUILDDIR/libcms-md5.* $INSTALLROOT/lib/
cp $BUILDDIR/edm_md5.h $INSTALLROOT/include/