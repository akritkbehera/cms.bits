package: cms-git-tools
version: "250807.0"
variables:
 commit: "62179e582d8d3dcb4f53027e8d8e1c360f307a08"
 branch: "master"
 fakerevision: shell(echo %(version)s | cut -d. -f1)
sources:
 - git://github.com/cms-sw/cms-git-tools.git?obj=%(branch)s/%(commit)s&export=cms-git-tools&output=/cms-git-tools-%(commit)s.tgz
build_requires:
 - gmake
requires:
 - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

mkdir -p $INSTALLROOT/common $INSTALLROOT/share/man/man1
cp -pR git-cms-* $INSTALLROOT/common
cp docs/man/man1/*.1 $INSTALLROOT/share/man/man1
find $INSTALLROOT/common -name '*' -type f -exec chmod +x {} \;
