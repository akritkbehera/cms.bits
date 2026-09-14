package: ninja
version: "v1.11.1"
sources:
  - https://github.com/ninja-build/ninja/archive/%(version)s.tar.gz
build_requires:
  - re2c
  - Python
requires:
  - gcc
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"
python3 ./configure.py --bootstrap

mkdir -p "$INSTALLROOT/bin"
cp ninja $INSTALLROOT/bin