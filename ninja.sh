package: ninja
version: "%(tag_basename)s"
tag: v1.11.1
source: https://github.com/ninja-build/ninja
build_requires:
  - re2c
  - python3
requires:
  - "gcc:(?gcc)"
---
rsync -a --chmod=ug=rwX --delete --exclude '**/.git' --delete-excluded "$SOURCEDIR"/ "$BUILDDIR"/
python3 ./configure.py --bootstrap

mkdir -p "$INSTALLROOT/bin"
cp ninja $INSTALLROOT/bin