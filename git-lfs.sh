package: git-lfs
version: 3.6.0
build_requires:
 - gmake
 - go
requires:
 - git
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

make ${JOBS:+-j$JOBS} VERSION=v$PKGVERSION GIT_LFS_SHA=$PKGVERSION
mkdir -p $INSTALLROOT/bin
mv bin/git-lfs $INSTALLROOT/bin
