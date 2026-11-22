package: ninja
version: "1.13.2"
sources:
  - https://github.com/ninja-build/ninja/archive/refs/tags/v%(version)s.tar.gz
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