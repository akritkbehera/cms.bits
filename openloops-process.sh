package: openloops-process
version: 2.1.2
sources:
 - https://github.com/akritkbehera/openloops/archive/refs/tags/%(version)s.tar.gz
patches:
 - openloops-urlopen2curl.patch
---
tar -xzf "$SOURCEDIR/${SOURCE0}" \
    --strip-components=1 \
    -C "$BUILDDIR"

patch -p1 < $PATCH0


