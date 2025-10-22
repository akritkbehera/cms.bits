package: eigen
version: "%(tag_basename)s"
tag: cms/master/3bb6a48d8c171cf20b5f8e48bfb4e424fbd4f79e
source: https://github.com/cms-externals/eigen-git-mirror
build_requires:
- CMake
- gcc
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' "$SOURCEDIR"/ "$PKGNAME-$PKGVERSION"/

cmake $PKGNAME-$PKGVERSION \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT" \
  -DBUILD_TESTING=OFF \
  -DCMAKE_CXX_STANDARD=20

make install
